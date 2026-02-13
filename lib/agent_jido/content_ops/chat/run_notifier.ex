defmodule AgentJido.ContentOps.Chat.RunNotifier do
  @moduledoc """
  Broadcasts completed ContentOps runs into bridged chat rooms.
  """

  use GenServer

  require Logger

  alias AgentJido.ContentOps.Chat.{Config, MessagePublisher}

  @pubsub_topic "contentops:runs"

  @doc "Starts the run notifier."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    Phoenix.PubSub.subscribe(AgentJido.PubSub, @pubsub_topic)

    state = %{
      room_ids: Keyword.get(opts, :room_ids, Config.room_ids()),
      publisher: Keyword.get(opts, :publisher, MessagePublisher)
    }

    {:ok, state}
  end

  @impl true
  def handle_info({:contentops_run_completed, report}, state) do
    text = format_report(report)

    Enum.each(state.room_ids, fn room_id ->
      case state.publisher.publish(room_id, text, %{event: "contentops.run.completed"}) do
        {:ok, _message} -> :ok
        {:error, reason} -> Logger.warning("[ContentOps.Chat.RunNotifier] publish failed: #{inspect(reason)}")
      end
    end)

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp format_report(report) do
    mode = report[:mode] || "unknown"
    run_id = report[:run_id] || "n/a"
    changes = get_in(report, [:stats, :change_requests]) || 0
    delivered = get_in(report, [:stats, :delivered]) || 0
    completed_at = report[:completed_at] || DateTime.utc_now()

    """
    ✅ ContentOps #{mode} run completed
    run_id: #{run_id}
    changes: #{changes}
    delivered: #{delivered}
    completed_at: #{format_time(completed_at)}
    """
    |> String.trim()
  end

  defp format_time(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp format_time(value), do: to_string(value)
end
