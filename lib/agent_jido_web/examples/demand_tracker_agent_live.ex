defmodule AgentJidoWeb.Examples.DemandTrackerAgentLive do
  @moduledoc """
  Interactive demo for the Demand Tracker Agent example.

  Runs the agent inside a `Jido.AgentServer` GenServer so declarative
  `schedules: [...]` are executed natively by the Jido runtime.

  The LiveView sends signals via `AgentServer.call/3` and polls agent state
  on a 1-second timer to reflect changes driven by scheduled signals.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.DemandTrackerAgent
  alias Jido.AgentServer
  alias Jido.Signal

  @poll_interval_ms 1_000

  @impl true
  def mount(_params, _session, socket) do
    # Start the agent inside an AgentServer so schedules are handled natively
    {:ok, pid} =
      AgentServer.start_link(
        jido: AgentJido.Jido,
        agent: DemandTrackerAgent,
        id: "demand-demo-#{System.unique_integer([:positive])}"
      )

    {:ok, server_state} = AgentServer.state(pid)
    agent = server_state.agent

    if connected?(socket) do
      Process.send_after(self(), :poll_state, @poll_interval_ms)
    end

    {:ok,
     socket
     |> assign(:server_pid, pid)
     |> assign(:agent, agent)
     |> assign(:history, [])}
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
    <div class="rounded-lg border border-border bg-card p-6 space-y-6">
      <%!-- Header --%>
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
          <div class="text-sm font-semibold text-foreground">Demand Tracker Agent</div>
        </div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          id: {@agent.id |> String.slice(0..7)}…
        </div>
      </div>

      <%!-- Demand Gauge --%>
      <div class="flex flex-col items-center py-6">
        <div class="relative w-full max-w-xs">
          <%!-- Background track --%>
          <div class="h-6 w-full rounded-full bg-elevated border border-border overflow-hidden">
            <%!-- Fill bar --%>
            <div
              class="h-full rounded-full transition-all duration-500 ease-out"
              style={"width: #{@agent.state.demand}%; background-color: #{demand_color(@agent.state.demand)};"}
            />
          </div>
          <%!-- Value label --%>
          <div class="absolute inset-0 flex items-center justify-center">
            <span class="text-xs font-bold text-foreground drop-shadow-sm tabular-nums">
              {@agent.state.demand}%
            </span>
          </div>
        </div>
        <div class="text-6xl font-bold text-primary tabular-nums tracking-tight mt-4">
          {@agent.state.demand}
        </div>
        <div class="text-xs text-muted-foreground mt-1">demand level (0–100)</div>
      </div>

      <%!-- Controls --%>
      <div class="flex items-center justify-center gap-3 flex-wrap">
        <button
          phx-click="cool"
          class="px-4 py-2 rounded-md bg-elevated border border-border text-foreground hover:border-blue-400/40 hover:bg-elevated/80 transition-colors text-sm font-semibold"
        >
          ❄ Cool −10
        </button>
        <button
          phx-click="heartbeat_tick"
          class="px-3 py-2 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-400 hover:bg-amber-500/20 transition-colors text-xs font-semibold"
        >
          ⏱ Heartbeat Tick
        </button>
        <button
          phx-click="cleanup"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-cyan-400/40 transition-colors text-xs"
        >
          🧹 Run Cleanup
        </button>
        <button
          phx-click="boost"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          🔥 Boost +10
        </button>
      </div>

      <%!-- Stats --%>
      <div class="grid grid-cols-3 gap-3">
        <div class="rounded-md bg-elevated border border-border p-3 text-center">
          <div class="text-lg font-bold text-foreground tabular-nums">
            {@agent.state.ticks}
          </div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider">
            Ticks
          </div>
        </div>
        <div class="rounded-md bg-elevated border border-border p-3 text-center">
          <div class="text-lg font-bold text-foreground tabular-nums">
            2
          </div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider">
            Schedules
          </div>
        </div>
        <div class="rounded-md bg-elevated border border-border p-3 text-center">
          <div class="text-xs font-mono text-foreground">
            {format_timestamp(@agent.state.last_updated_at)}
          </div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider">
            Last Updated
          </div>
        </div>
      </div>

      <%!-- Schedule config --%>
      <div class="rounded-md bg-elevated border border-border p-3 space-y-1">
        <div class="text-[10px] text-muted-foreground uppercase tracking-wider">
          Configured Schedules
        </div>
        <div class="text-xs font-mono text-foreground">
          */5 * * * * → heartbeat.tick (job_id: :heartbeat)
        </div>
        <div class="text-xs font-mono text-foreground">
          @daily → cleanup.run (job_id: :cleanup, timezone: America/New_York)
        </div>
      </div>

      <%!-- Signal / Schedule Log --%>
      <div :if={@history != []} class="border-t border-border pt-4">
        <div class="flex items-center justify-between mb-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
            Signal &amp; Schedule Log
          </div>
          <div class="text-[10px] text-muted-foreground">
            {length(@history)} event{if length(@history) != 1, do: "s"}
          </div>
        </div>
        <div class="space-y-1 max-h-56 overflow-y-auto">
          <%= for entry <- Enum.take(@history, 30) do %>
            <div class="flex items-start gap-2 text-xs font-mono py-1 px-2 rounded bg-elevated/50">
              <span class={directive_badge_class(entry.kind)}>{entry.kind}</span>
              <span class="text-primary shrink-0">{entry.signal_type}</span>
              <span class="text-muted-foreground/60 shrink-0">
                {entry.from} → {entry.to}
              </span>
              <span :if={entry.detail != ""} class="text-muted-foreground/40 ml-auto truncate max-w-[200px]">
                {entry.detail}
              </span>
            </div>
          <% end %>
        </div>
      </div>

      <%!-- Raw agent state --%>
      <details class="border-t border-border pt-4 group">
        <summary class="text-[10px] uppercase tracking-wider text-muted-foreground cursor-pointer hover:text-foreground transition-colors select-none">
          Raw Agent State <span class="text-muted-foreground/40 group-open:hidden">▸</span>
          <span class="text-muted-foreground/40 hidden group-open:inline">▾</span>
        </summary>
        <pre class="mt-2 p-3 rounded-md bg-elevated border border-border text-xs text-muted-foreground font-mono overflow-x-auto whitespace-pre-wrap"><%= inspect(@agent, pretty: true, width: 60) %></pre>
      </details>
    </div>
    """
  end

  # ── Event Handlers ──────────────────────────────────────────

  @impl true
  def handle_event("boost", _params, socket) do
    {:noreply, send_signal(socket, "listing.demand.boost", %{amount: 10})}
  end

  def handle_event("cool", _params, socket) do
    {:noreply, send_signal(socket, "listing.demand.cool", %{amount: 10})}
  end

  def handle_event("heartbeat_tick", _params, socket) do
    {:noreply, send_signal(socket, "heartbeat.tick", %{})}
  end

  def handle_event("cleanup", _params, socket) do
    {:noreply, send_signal(socket, "cleanup.run", %{})}
  end

  # ── Info Handlers ───────────────────────────────────────────

  @impl true
  def handle_info(:poll_state, socket) do
    socket = refresh_agent_state(socket)
    Process.send_after(self(), :poll_state, @poll_interval_ms)
    {:noreply, socket}
  end

  # ── Helpers ─────────────────────────────────────────────────

  defp send_signal(socket, signal_type, data) do
    pid = socket.assigns.server_pid
    old_demand = socket.assigns.agent.state.demand
    old_ticks = socket.assigns.agent.state.ticks

    signal = Signal.new!(signal_type, data, source: "/demo/demand-tracker-live")

    case AgentServer.call(pid, signal) do
      {:ok, new_agent} ->
        new_demand = new_agent.state.demand
        new_ticks = new_agent.state.ticks

        detail =
          case signal_type do
            "cleanup.run" -> "ticks #{old_ticks} -> #{new_ticks}"
            _ -> if(data == %{}, do: "", else: inspect(data))
          end

        entry = %{
          kind: "signal",
          signal_type: signal_type,
          from: old_demand,
          to: new_demand,
          detail: detail,
          at: DateTime.utc_now()
        }

        socket
        |> assign(:agent, new_agent)
        |> assign(:history, [entry | socket.assigns.history])

      {:error, reason} ->
        entry = %{
          kind: "error",
          signal_type: signal_type,
          from: old_demand,
          to: old_demand,
          detail: inspect(reason),
          at: DateTime.utc_now()
        }

        assign(socket, :history, [entry | socket.assigns.history])
    end
  end

  defp refresh_agent_state(socket) do
    pid = socket.assigns.server_pid

    case AgentServer.state(pid) do
      {:ok, server_state} ->
        new_agent = server_state.agent
        old_agent = socket.assigns.agent

        entries = []

        entries =
          if new_agent.state.ticks > old_agent.state.ticks and
               new_agent.state.demand < old_agent.state.demand do
            ticks_diff = new_agent.state.ticks - old_agent.state.ticks

            [
              %{
                kind: "schedule",
                signal_type: "heartbeat.tick (scheduled)",
                from: old_agent.state.demand,
                to: new_agent.state.demand,
                detail: "#{ticks_diff} tick(s) via */5 * * * *",
                at: DateTime.utc_now()
              }
              | entries
            ]
          else
            entries
          end

        entries =
          if new_agent.state.ticks < old_agent.state.ticks do
            [
              %{
                kind: "schedule",
                signal_type: "cleanup.run (scheduled)",
                from: old_agent.state.ticks,
                to: new_agent.state.ticks,
                detail: "@daily cleanup reset tick counter",
                at: DateTime.utc_now()
              }
              | entries
            ]
          else
            entries
          end

        socket =
          if entries == [] do
            socket
          else
            assign(socket, :history, entries ++ socket.assigns.history)
          end

        assign(socket, :agent, new_agent)

      {:error, _} ->
        socket
    end
  end

  defp demand_color(demand) when demand >= 80, do: "#22c55e"
  defp demand_color(demand) when demand >= 60, do: "#84cc16"
  defp demand_color(demand) when demand >= 40, do: "#eab308"
  defp demand_color(demand) when demand >= 20, do: "#f97316"
  defp demand_color(_demand), do: "#ef4444"

  defp format_timestamp(nil), do: "—"

  defp format_timestamp(%DateTime{} = dt) do
    Calendar.strftime(dt, "%H:%M:%S")
  end

  defp format_timestamp(_other), do: "—"

  defp directive_badge_class("signal"),
    do: "text-emerald-400 bg-emerald-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"

  defp directive_badge_class("schedule"),
    do: "text-amber-400 bg-amber-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"

  defp directive_badge_class("error"),
    do: "text-red-400 bg-red-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"

  defp directive_badge_class(_),
    do: "text-muted-foreground bg-elevated px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"
end
