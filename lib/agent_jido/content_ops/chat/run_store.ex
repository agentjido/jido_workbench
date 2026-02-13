defmodule AgentJido.ContentOps.Chat.RunStore do
  @moduledoc """
  In-memory cache of recent ContentOps run reports.
  """

  use GenServer

  @default_max_reports 50
  @pubsub_topic "contentops:runs"

  @type report :: map()

  @doc "Starts the run store process."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc "Returns recent reports (newest first)."
  @spec recent(non_neg_integer()) :: [report()]
  def recent(limit \\ 10) when is_integer(limit) and limit >= 0 do
    GenServer.call(__MODULE__, {:recent, limit})
  end

  @doc "Pushes a report into the cache (mainly for tests)."
  @spec push(report()) :: :ok
  def push(report) when is_map(report) do
    GenServer.cast(__MODULE__, {:push, report})
  end

  @doc "Clears all reports from the cache."
  @spec clear() :: :ok
  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  @impl true
  def init(opts) do
    if Keyword.get(opts, :subscribe, true) do
      Phoenix.PubSub.subscribe(AgentJido.PubSub, @pubsub_topic)
    end

    state = %{
      reports: [],
      max_reports: Keyword.get(opts, :max_reports, @default_max_reports)
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:recent, limit}, _from, state) do
    {:reply, Enum.take(state.reports, limit), state}
  end

  @impl true
  def handle_cast({:push, report}, state) do
    {:noreply, put_report(state, report)}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | reports: []}}
  end

  @impl true
  def handle_info({:contentops_run_completed, report}, state) do
    {:noreply, put_report(state, report)}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp put_report(state, report) do
    reports =
      [report | state.reports]
      |> Enum.take(state.max_reports)

    %{state | reports: reports}
  end
end
