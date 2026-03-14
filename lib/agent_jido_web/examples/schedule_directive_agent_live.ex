defmodule AgentJidoWeb.Examples.ScheduleDirectiveAgentLive do
  @moduledoc """
  Interactive demo for schedule directives and CRON schedules.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.ScheduleDirectiveAgent
  alias Jido.AgentServer
  alias Jido.Signal

  @poll_interval_ms 250

  @impl true
  def mount(_params, _session, socket) do
    fallback_agent = ScheduleDirectiveAgent.new(id: "schedule-directive-preview")

    socket =
      socket
      |> assign(:server_pid, nil)
      |> assign(:agent, fallback_agent)
      |> assign(:timer_delay_ms, 120)
      |> assign(:retry_max_attempts, 3)
      |> assign(:retry_delay_ms, 80)
      |> assign(:log_entries, [])
      |> assign(:last_error, nil)

    socket =
      if connected?(socket) do
        case start_demo_server() do
          {:ok, pid, agent} ->
            Process.send_after(self(), :poll_state, @poll_interval_ms)
            socket |> assign(:server_pid, pid) |> assign(:agent, agent)

          {:error, reason} ->
            assign(socket, :last_error, "Failed to start runtime: #{inspect(reason)}")
        end
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    if pid = socket.assigns[:server_pid] do
      if Process.alive?(pid), do: GenServer.stop(pid, :normal)
    end

    :ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="schedule-directive-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="text-sm font-semibold text-foreground">Schedule Directive Agent</div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          status: {@agent.state.status}
        </div>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 px-3 py-2 text-xs text-red-300">
        {@last_error}
      </div>

      <div class="rounded-md border border-border bg-elevated p-3 space-y-1">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Configured CRON schedules</div>
        <div id="schedule-cron-lines" class="text-xs font-mono text-foreground">*/1 * * * * → cron.tick</div>
        <div class="text-xs font-mono text-foreground">0 * * * * → cron.hourly</div>
      </div>

      <div class="grid sm:grid-cols-4 gap-3">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Timer Ticks</div>
          <div id="schedule-tick-count" class="text-lg font-bold text-foreground mt-1">{@agent.state.tick_count}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Retry Attempts</div>
          <div id="schedule-attempts" class="text-lg font-bold text-foreground mt-1">{@agent.state.attempts}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">CRON Ticks</div>
          <div id="schedule-cron-count" class="text-lg font-bold text-foreground mt-1">{@agent.state.cron_ticks}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Last Event</div>
          <div class="text-xs font-semibold text-foreground mt-2">{if @agent.state.last_event == "", do: "—", else: @agent.state.last_event}</div>
        </div>
      </div>

      <div class="grid gap-3 md:grid-cols-3">
        <form id="schedule-start-timer-form" phx-submit="start_timer" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">call: start_timer</div>
          <input
            type="number"
            name="delay_ms"
            value={@timer_delay_ms}
            min="10"
            class="w-full px-2 py-1 text-sm rounded-md bg-background border border-border"
          />
          <button type="submit" class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary text-xs font-semibold">
            Schedule Timer
          </button>
        </form>

        <form id="schedule-start-retry-form" phx-submit="start_retry" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">call: start_retry</div>
          <input
            type="number"
            name="max_attempts"
            value={@retry_max_attempts}
            min="1"
            max="10"
            class="w-full px-2 py-1 text-sm rounded-md bg-background border border-border"
          />
          <input
            type="number"
            name="delay_ms"
            value={@retry_delay_ms}
            min="10"
            class="w-full px-2 py-1 text-sm rounded-md bg-background border border-border"
          />
          <button type="submit" class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary text-xs font-semibold">
            Start Retry
          </button>
        </form>

        <div class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">manual CRON tick</div>
          <button
            id="schedule-manual-cron-btn"
            phx-click="manual_cron_tick"
            class="w-full px-3 py-1 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-400 text-xs font-semibold"
          >
            Send cron.tick now
          </button>
          <button
            id="schedule-manual-hourly-btn"
            phx-click="manual_cron_hourly"
            class="w-full px-3 py-1 rounded-md bg-elevated border border-border text-xs hover:border-primary/40"
          >
            Send cron.hourly now
          </button>
        </div>
      </div>

      <div class="border-t border-border pt-4">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Execution Log</div>
        <div :if={@log_entries == []} class="text-xs text-muted-foreground">Run schedule actions to inspect state transitions.</div>
        <div :if={@log_entries != []} class="space-y-1 max-h-56 overflow-y-auto">
          <%= for entry <- @log_entries do %>
            <div class="rounded-md border border-border bg-elevated/60 px-3 py-2 text-xs">
              <span class="font-semibold text-foreground">{entry.action}</span>
              <span class="text-muted-foreground ml-2">{entry.detail}</span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("start_timer", %{"delay_ms" => delay_raw}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, delay_ms} <- parse_positive_integer(delay_raw) do
      timer_id = "T-#{System.unique_integer([:positive])}"

      signal = Signal.new!("start_timer", %{delay_ms: delay_ms, timer_id: timer_id}, source: "/demo")

      case AgentServer.call(pid, signal) do
        {:ok, agent} ->
          {:noreply,
           socket
           |> assign(:agent, agent)
           |> assign(:timer_delay_ms, delay_ms)
           |> assign(:last_error, nil)
           |> append_log("start_timer", "delay=#{delay_ms}ms id=#{timer_id}")}

        {:error, reason} ->
          {:noreply, assign(socket, :last_error, inspect(reason))}
      end
    else
      {:error, reason} -> {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  def handle_event("start_retry", %{"max_attempts" => max_raw, "delay_ms" => delay_raw}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, max_attempts} <- parse_positive_integer(max_raw),
         {:ok, delay_ms} <- parse_positive_integer(delay_raw) do
      signal =
        Signal.new!(
          "start_retry",
          %{max_attempts: max_attempts, retry_delay_ms: delay_ms},
          source: "/demo"
        )

      case AgentServer.call(pid, signal) do
        {:ok, agent} ->
          {:noreply,
           socket
           |> assign(:agent, agent)
           |> assign(:retry_max_attempts, max_attempts)
           |> assign(:retry_delay_ms, delay_ms)
           |> assign(:last_error, nil)
           |> append_log("start_retry", "max=#{max_attempts}, delay=#{delay_ms}ms")}

        {:error, reason} ->
          {:noreply, assign(socket, :last_error, inspect(reason))}
      end
    else
      {:error, reason} -> {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  def handle_event("manual_cron_tick", _params, socket) do
    send_manual_cron(socket, "cron.tick", "manual cron.tick")
  end

  def handle_event("manual_cron_hourly", _params, socket) do
    send_manual_cron(socket, "cron.hourly", "manual cron.hourly")
  end

  @impl true
  def handle_info(:poll_state, socket) do
    socket =
      case fetch_server_pid(socket) do
        {:ok, pid} ->
          case AgentServer.state(pid) do
            {:ok, %{agent: agent}} -> assign(socket, :agent, agent)
            _ -> socket
          end

        _ ->
          socket
      end

    Process.send_after(self(), :poll_state, @poll_interval_ms)
    {:noreply, socket}
  end

  defp send_manual_cron(socket, signal_type, log_label) do
    case fetch_server_pid(socket) do
      {:ok, pid} ->
        case AgentServer.call(pid, Signal.new!(signal_type, %{}, source: "/demo")) do
          {:ok, agent} ->
            {:noreply,
             socket
             |> assign(:agent, agent)
             |> assign(:last_error, nil)
             |> append_log(log_label, "cron_ticks=#{agent.state.cron_ticks}")}

          {:error, reason} ->
            {:noreply, assign(socket, :last_error, inspect(reason))}
        end

      {:error, reason} ->
        {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  defp start_demo_server do
    id = "schedule-directive-demo-#{System.unique_integer([:positive])}"

    with {:ok, pid} <- AgentServer.start_link(jido: AgentJido.Jido, agent: ScheduleDirectiveAgent, id: id),
         {:ok, %{agent: agent}} <- AgentServer.state(pid) do
      {:ok, pid, agent}
    end
  end

  defp fetch_server_pid(socket) do
    case socket.assigns.server_pid do
      pid when is_pid(pid) -> if(Process.alive?(pid), do: {:ok, pid}, else: {:error, :runtime_not_started})
      _ -> {:error, :runtime_not_started}
    end
  end

  defp parse_positive_integer(raw) do
    case Integer.parse(to_string(raw)) do
      {value, ""} when value >= 1 -> {:ok, value}
      _other -> {:error, :invalid_integer}
    end
  end

  defp append_log(socket, action, detail) do
    entry = %{action: action, detail: detail, at: DateTime.utc_now()}
    assign(socket, :log_entries, [entry | socket.assigns.log_entries] |> Enum.take(40))
  end
end
