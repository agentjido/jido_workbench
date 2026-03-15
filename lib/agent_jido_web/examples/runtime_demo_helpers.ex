defmodule AgentJidoWeb.Examples.RuntimeDemoHelpers do
  @moduledoc false

  alias Jido.AgentServer

  def start_runtime(socket, start_fun, poll_interval_ms, opts \\ []) when is_function(start_fun, 0) do
    if Phoenix.LiveView.connected?(socket) do
      case start_fun.() do
        {:ok, pid, agent} ->
          Process.send_after(self(), :poll_state, poll_interval_ms)

          socket
          |> Phoenix.Component.assign(:server_pid, pid)
          |> Phoenix.Component.assign(:agent, agent)

        {:error, reason} ->
          Phoenix.Component.assign(
            socket,
            :last_error,
            "#{Keyword.get(opts, :start_error_prefix, "Failed to start runtime")}: #{inspect(reason)}"
          )
      end
    else
      socket
    end
  end

  def stop_runtime(socket) do
    if pid = socket.assigns[:server_pid] do
      if Process.alive?(pid), do: GenServer.stop(pid, :normal)
    end

    :ok
  end

  def refresh_agent(socket) do
    case fetch_server_pid(socket) do
      {:ok, pid} ->
        case AgentServer.state(pid) do
          {:ok, %{agent: agent}} -> Phoenix.Component.assign(socket, :agent, agent)
          _ -> socket
        end

      _ ->
        socket
    end
  end

  def fetch_server_pid(socket) do
    case socket.assigns.server_pid do
      pid when is_pid(pid) -> if(Process.alive?(pid), do: {:ok, pid}, else: {:error, :runtime_not_started})
      _ -> {:error, :runtime_not_started}
    end
  end
end
