defmodule AgentJidoWeb.ContentOpsLive do
  @moduledoc """
  LiveView dashboard for visualizing and testing the ContentOps agent system.

  Provides:
  - Orchestrator server health and state inspection
  - Workflow pipeline visualization
  - Manual run triggers with mode selection
  - Real-time run history with expandable details

  Subscribes to `contentops:runs` PubSub topic and polls server status.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.ContentOps.OrchestratorAgent

  @server_name AgentJido.ContentOps.OrchestratorServer
  @poll_interval_ms 3_000
  @max_runs 30

  @pipeline_steps [
    {:build_run_context, "BuildRunContext", "Creates run ID, mode, timestamps"},
    {:load_policy_bundle, "LoadPolicyBundle", "Loads governance policies"},
    {:select_work, "SelectWork", "Selects work from content backlog"},
    {:collect_change_requests, "CollectChangeRequests", "Aggregates change requests"},
    {:delivery_sink, "DeliverySink", "Records/delivers changes"},
    {:publish_run_report, "PublishRunReport", "Broadcasts completion report"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AgentJido.PubSub, "contentops:runs")
      :timer.send_interval(@poll_interval_ms, self(), :poll_server)
    end

    socket =
      socket
      |> assign(:runs, [])
      |> assign(:running, false)
      |> assign(:current_mode, nil)
      |> assign(:selected_mode, :weekly)
      |> assign(:run_task_ref, nil)
      |> assign(:expanded_run_ids, MapSet.new())
      |> assign(:server_status, nil)
      |> assign(:server_state_summary, nil)
      |> assign(:server_error, nil)
      |> assign(:show_raw_state, false)
      |> assign(:raw_state_text, nil)
      |> assign(:last_refreshed_at, nil)
      |> assign(:pipeline_steps, @pipeline_steps)
      |> refresh_server_status()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container max-w-5xl mx-auto px-6 py-12 space-y-6">
      <%!-- Header --%>
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-foreground">ContentOps Dashboard</h1>
          <p class="text-sm text-muted-foreground mt-1">
            Visualize and test the ContentOps agent system
          </p>
        </div>
        <div class="flex items-center gap-3">
          <.link navigate="/dev/contentops/github" class="text-sm text-primary hover:text-primary/80 transition-colors">
            GitHub Issues &amp; PRs →
          </.link>
          <div :if={@running} class="flex items-center gap-2 text-sm text-amber-400">
            <div class="h-2 w-2 rounded-full bg-amber-400 animate-pulse" /> Running {@current_mode}…
          </div>
          <div :if={@last_refreshed_at} class="text-[10px] text-muted-foreground font-mono">
            polled {format_timestamp(@last_refreshed_at)}
          </div>
        </div>
      </div>

      <%!-- Server Status Card --%>
      <.server_status_card
        server_status={@server_status}
        server_state_summary={@server_state_summary}
        server_error={@server_error}
        show_raw_state={@show_raw_state}
        raw_state_text={@raw_state_text}
      />

      <%!-- Workflow Pipeline Card --%>
      <.pipeline_card steps={@pipeline_steps} running={@running} />

      <%!-- Trigger Run Card --%>
      <.trigger_card selected_mode={@selected_mode} running={@running} />

      <%!-- Run History Card --%>
      <.run_history_card runs={@runs} expanded_run_ids={@expanded_run_ids} />
    </div>
    """
  end

  # ── Server Status Card ────────────────────────────────────────────

  defp server_status_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-border bg-card p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-sm font-semibold text-foreground">Orchestrator Server</h2>
        <button
          phx-click="refresh_server"
          class="text-xs text-muted-foreground hover:text-foreground transition-colors"
        >
          ↻ Refresh
        </button>
      </div>

      <div :if={@server_error} class="text-sm text-red-400 mb-3">
        <span class="font-mono">⚠ {@server_error}</span>
      </div>

      <div :if={@server_status} class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4">
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">Status</div>
          <div class={"text-sm font-semibold " <> server_status_color(@server_status.status)}>
            {@server_status.status}
          </div>
        </div>
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">Agent</div>
          <div class="text-sm font-mono text-foreground truncate">{@server_status.agent_module}</div>
        </div>
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">Agent ID</div>
          <div class="text-sm font-mono text-foreground truncate">{@server_status.agent_id}</div>
        </div>
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">PID</div>
          <div class="text-sm font-mono text-foreground">{@server_status.pid}</div>
        </div>
      </div>

      <div :if={@server_state_summary} class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4">
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">
            Total Runs
          </div>
          <div class="text-sm font-bold text-foreground tabular-nums">
            {@server_state_summary.total_runs}
          </div>
        </div>
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">
            Last Mode
          </div>
          <div class="text-sm text-foreground">
            {if @server_state_summary.last_run_mode,
              do: "#{mode_emoji(@server_state_summary.last_run_mode)} #{@server_state_summary.last_run_mode}",
              else: "—"}
          </div>
        </div>
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">
            Last Run ID
          </div>
          <div class="text-xs font-mono text-foreground truncate">
            {@server_state_summary.last_run_id || "—"}
          </div>
        </div>
        <div>
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">
            Last Run At
          </div>
          <div class="text-xs font-mono text-foreground">
            {if @server_state_summary.last_run_at, do: format_timestamp(@server_state_summary.last_run_at), else: "—"}
          </div>
        </div>
      </div>

      <div :if={not is_nil(@server_status)}>
        <button
          phx-click="toggle_raw_state"
          class="text-xs text-muted-foreground hover:text-foreground transition-colors"
        >
          {if @show_raw_state, do: "▾ Hide", else: "▸ Show"} raw state
        </button>
        <div :if={@show_raw_state} class="mt-2">
          <pre class="text-[11px] font-mono text-muted-foreground bg-elevated rounded-md p-4 overflow-x-auto max-h-64 overflow-y-auto border border-border">{@raw_state_text}</pre>
        </div>
      </div>

      <div
        :if={is_nil(@server_status) and is_nil(@server_error)}
        class="text-sm text-muted-foreground"
      >
        Connecting…
      </div>
    </div>
    """
  end

  # ── Workflow Pipeline Card ─────────────────────────────────────────

  defp pipeline_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-border bg-card p-6">
      <h2 class="text-sm font-semibold text-foreground mb-4">Workflow Pipeline</h2>
      <div class="flex items-center gap-1 overflow-x-auto pb-2">
        <div :for={{step, idx} <- Enum.with_index(@steps)} class="flex items-center">
          <div :if={idx > 0} class="text-muted-foreground mx-1 shrink-0">→</div>
          <.pipeline_step_badge step={step} running={@running} index={idx} total={length(@steps)} />
        </div>
      </div>
    </div>
    """
  end

  defp pipeline_step_badge(assigns) do
    {_key, label, desc} = assigns.step

    assigns =
      assigns
      |> assign(:label, label)
      |> assign(:desc, desc)

    ~H"""
    <div
      class="group relative shrink-0 rounded-md border px-3 py-2 text-center transition-colors border-border bg-elevated"
      title={@desc}
    >
      <div class="text-[11px] font-semibold text-foreground whitespace-nowrap">{@label}</div>
      <div class="text-[9px] text-muted-foreground mt-0.5">{step_number(@index + 1)}</div>
      <div class="absolute -bottom-6 left-1/2 -translate-x-1/2 hidden group-hover:block bg-card border border-border rounded px-2 py-1 text-[10px] text-muted-foreground whitespace-nowrap z-10 shadow-lg">
        {@desc}
      </div>
    </div>
    """
  end

  # ── Trigger Run Card ───────────────────────────────────────────────

  defp trigger_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-border bg-card p-6">
      <h2 class="text-sm font-semibold text-foreground mb-4">Trigger Run</h2>
      <div class="flex items-center gap-4 flex-wrap">
        <div class="flex items-center rounded-md border border-border bg-elevated overflow-hidden">
          <button
            :for={mode <- [:hourly, :nightly, :weekly, :monthly]}
            phx-click="select_mode"
            phx-value-mode={mode}
            class={"px-4 py-2 text-sm font-semibold transition-colors " <>
              if(mode == @selected_mode,
                do: "bg-primary/20 text-primary border-r border-primary/30",
                else: "text-muted-foreground hover:text-foreground border-r border-border"
              )}
          >
            {mode_emoji(mode)} {mode}
          </button>
        </div>
        <button
          phx-click="trigger_run"
          disabled={@running}
          class={"px-6 py-2 rounded-md text-sm font-semibold transition-colors " <>
            if(@running,
              do: "bg-muted text-muted-foreground cursor-not-allowed",
              else: "bg-primary text-primary-foreground hover:bg-primary/90"
            )}
        >
          {if @running, do: "Running…", else: "▶ Run #{@selected_mode}"}
        </button>
      </div>
      <p class="text-[11px] text-muted-foreground mt-3">
        <span class="font-semibold">hourly/nightly</span>
        = maintenance only (0 changes) · <span class="font-semibold">weekly/monthly</span>
        = creation sprint (synthetic work orders)
      </p>
    </div>
    """
  end

  # ── Run History Card ───────────────────────────────────────────────

  defp run_history_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-border bg-card p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-sm font-semibold text-foreground">Run History</h2>
        <span class="text-xs text-muted-foreground">{length(@runs)} run(s)</span>
      </div>

      <div :if={@runs == []} class="text-center py-8 text-muted-foreground text-sm">
        No runs yet. Trigger a run above or use <code class="bg-elevated px-1.5 py-0.5 rounded text-xs">mix agentjido.signal</code>
      </div>

      <div :if={@runs != []} class="space-y-3">
        <.run_entry
          :for={run <- @runs}
          run={run}
          expanded={MapSet.member?(@expanded_run_ids, run.run_id)}
        />
      </div>
    </div>
    """
  end

  defp run_entry(assigns) do
    ~H"""
    <div class="rounded-md bg-elevated border border-border">
      <button
        phx-click="toggle_run"
        phx-value-run-id={@run.run_id}
        class="w-full text-left p-4 flex items-center justify-between hover:bg-elevated/80 transition-colors"
      >
        <div class="flex items-center gap-3">
          <span class={status_badge_class(@run.status)}>
            {status_label(@run.status)}
          </span>
          <span class="text-sm font-semibold text-foreground">
            {mode_emoji(@run.mode)} {@run.mode}
          </span>
          <div class="flex items-center gap-4 text-xs text-muted-foreground">
            <span>{@run.stats.change_requests} changes</span>
            <span>{@run.stats.delivered} delivered</span>
          </div>
        </div>
        <div class="flex items-center gap-3">
          <span class="text-xs font-mono text-muted-foreground">
            {format_timestamp(@run.completed_at)}
          </span>
          <span class="text-muted-foreground text-xs">{if @expanded, do: "▾", else: "▸"}</span>
        </div>
      </button>

      <div :if={@expanded} class="border-t border-border p-4 space-y-3">
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div>
            <div class="text-[10px] text-muted-foreground uppercase tracking-wider">Run ID</div>
            <div class="text-xs font-mono text-foreground mt-0.5">{@run.run_id}</div>
          </div>
          <div>
            <div class="text-[10px] text-muted-foreground uppercase tracking-wider">Started</div>
            <div class="text-xs font-mono text-foreground mt-0.5">
              {format_timestamp(@run.started_at)}
            </div>
          </div>
          <div>
            <div class="text-[10px] text-muted-foreground uppercase tracking-wider">Completed</div>
            <div class="text-xs font-mono text-foreground mt-0.5">
              {format_timestamp(@run.completed_at)}
            </div>
          </div>
          <div>
            <div class="text-[10px] text-muted-foreground uppercase tracking-wider">Duration</div>
            <div class="text-xs font-mono text-foreground mt-0.5">
              {format_duration(@run.started_at, @run.completed_at)}
            </div>
          </div>
        </div>

        <div :if={@run[:productions] && @run.productions != []} class="mt-3">
          <div class="text-[10px] text-muted-foreground uppercase tracking-wider mb-2">
            Productions ({length(@run.productions)})
          </div>
          <div class="space-y-2">
            <div
              :for={prod <- @run.productions}
              class="rounded border border-border bg-card p-3"
            >
              <div class="text-xs font-mono text-foreground">{inspect_production(prod)}</div>
            </div>
          </div>
        </div>

        <div :if={is_nil(@run[:productions]) or @run[:productions] == []} class="mt-2">
          <div class="text-xs text-muted-foreground italic">
            No production details available for this run.
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ── Events ─────────────────────────────────────────────────────────

  @impl true
  def handle_event("select_mode", %{"mode" => mode_str}, socket) do
    mode =
      if mode_str in ~w(hourly nightly weekly monthly),
        do: String.to_existing_atom(mode_str),
        else: :weekly

    {:noreply, assign(socket, :selected_mode, mode)}
  end

  def handle_event("trigger_run", _params, socket) do
    mode = socket.assigns.selected_mode
    socket = socket |> assign(:running, true) |> assign(:current_mode, mode)

    task =
      Task.async(fn ->
        OrchestratorAgent.run(mode: mode, timeout: 30_000)
      end)

    {:noreply, assign(socket, :run_task_ref, task.ref)}
  end

  def handle_event("refresh_server", _params, socket) do
    {:noreply, refresh_server_status(socket)}
  end

  def handle_event("toggle_raw_state", _params, socket) do
    {:noreply, assign(socket, :show_raw_state, !socket.assigns.show_raw_state)}
  end

  def handle_event("toggle_run", %{"run-id" => run_id}, socket) do
    expanded = socket.assigns.expanded_run_ids

    expanded =
      if MapSet.member?(expanded, run_id),
        do: MapSet.delete(expanded, run_id),
        else: MapSet.put(expanded, run_id)

    {:noreply, assign(socket, :expanded_run_ids, expanded)}
  end

  # ── Info handlers ──────────────────────────────────────────────────

  @impl true
  def handle_info({:contentops_run_completed, report}, socket) do
    run_entry = %{
      run_id: report.run_id,
      mode: report.mode,
      status: :completed,
      stats: report.stats,
      started_at: report.started_at,
      completed_at: report.completed_at,
      productions: nil
    }

    runs = merge_run(socket.assigns.runs, run_entry)
    {:noreply, assign(socket, :runs, runs)}
  end

  # Task completion — merge productions into run
  def handle_info({ref, result}, socket) when ref == socket.assigns.run_task_ref do
    Process.demonitor(ref, [:flush])

    socket = socket |> assign(:running, false) |> assign(:current_mode, nil) |> assign(:run_task_ref, nil)

    socket =
      case result do
        %{mode: _mode, productions: productions, status: :completed} ->
          # Try to find the report to get the run_id
          report = OrchestratorAgent.run_report(result)
          run_id = if report, do: report.run_id, else: nil

          if run_id do
            runs =
              Enum.map(socket.assigns.runs, fn run ->
                if run.run_id == run_id, do: Map.put(run, :productions, productions), else: run
              end)

            assign(socket, :runs, runs)
          else
            socket
          end

        _ ->
          socket
      end

    {:noreply, refresh_server_status(socket)}
  end

  # Task crash
  def handle_info({:DOWN, ref, :process, _pid, _reason}, socket)
      when ref == socket.assigns.run_task_ref do
    {:noreply,
     socket
     |> assign(:running, false)
     |> assign(:current_mode, nil)
     |> assign(:run_task_ref, nil)}
  end

  def handle_info(:poll_server, socket) do
    {:noreply, refresh_server_status(socket)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  # ── Server status helpers ──────────────────────────────────────────

  defp refresh_server_status(socket) do
    case Jido.AgentServer.status(@server_name) do
      {:ok, status} ->
        state_summary = extract_state_summary(status.raw_state)

        raw_text =
          inspect(
            %{
              status: status.snapshot.status,
              agent_id: status.agent_id,
              raw_state: status.raw_state,
              snapshot: status.snapshot
            },
            pretty: true,
            limit: 500,
            width: 80
          )

        socket
        |> assign(:server_status, %{
          status: status.snapshot.status,
          agent_module: inspect(status.agent_module),
          agent_id: status.agent_id,
          pid: inspect(status.pid)
        })
        |> assign(:server_state_summary, state_summary)
        |> assign(:server_error, nil)
        |> assign(:raw_state_text, raw_text)
        |> assign(:last_refreshed_at, DateTime.utc_now())

      {:error, reason} ->
        socket
        |> assign(:server_status, nil)
        |> assign(:server_state_summary, nil)
        |> assign(:server_error, inspect(reason))
        |> assign(:last_refreshed_at, DateTime.utc_now())
    end
  end

  defp extract_state_summary(raw_state) when is_map(raw_state) do
    %{
      total_runs: Map.get(raw_state, :total_runs, 0),
      last_run_id: Map.get(raw_state, :last_run_id),
      last_run_mode: Map.get(raw_state, :last_run_mode),
      last_run_at: Map.get(raw_state, :last_run_at)
    }
  end

  defp extract_state_summary(_), do: %{total_runs: 0, last_run_id: nil, last_run_mode: nil, last_run_at: nil}

  # ── Run list helpers ───────────────────────────────────────────────

  defp merge_run(runs, new_run) do
    case Enum.find_index(runs, &(&1.run_id == new_run.run_id)) do
      nil -> Enum.take([new_run | runs], @max_runs)
      idx -> List.update_at(runs, idx, &Map.merge(&1, new_run))
    end
  end

  # ── Format helpers ─────────────────────────────────────────────────

  defp mode_emoji(:hourly), do: "⏱"
  defp mode_emoji(:nightly), do: "🌙"
  defp mode_emoji(:weekly), do: "📅"
  defp mode_emoji(:monthly), do: "📊"
  defp mode_emoji(_), do: "•"

  defp status_badge_class(:completed),
    do: "text-emerald-400 bg-emerald-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase font-semibold shrink-0"

  defp status_badge_class(:failed),
    do: "text-red-400 bg-red-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase font-semibold shrink-0"

  defp status_badge_class(_),
    do: "text-muted-foreground bg-elevated px-1.5 py-0.5 rounded text-[10px] uppercase font-semibold shrink-0"

  defp status_label(:completed), do: "✓ completed"
  defp status_label(:failed), do: "✗ failed"
  defp status_label(other), do: "#{other}"

  defp server_status_color(:idle), do: "text-emerald-400"
  defp server_status_color(:running), do: "text-amber-400"
  defp server_status_color(:waiting), do: "text-blue-400"
  defp server_status_color(_), do: "text-muted-foreground"

  defp format_timestamp(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
  defp format_timestamp(_), do: "—"

  defp format_duration(%DateTime{} = started, %DateTime{} = completed) do
    diff_ms = DateTime.diff(completed, started, :millisecond)

    cond do
      diff_ms < 1_000 -> "#{diff_ms}ms"
      diff_ms < 60_000 -> "#{Float.round(diff_ms / 1_000, 1)}s"
      true -> "#{div(diff_ms, 60_000)}m #{rem(div(diff_ms, 1_000), 60)}s"
    end
  end

  defp format_duration(_, _), do: "—"

  defp step_number(n), do: "Step #{n}"

  defp inspect_production(prod) when is_map(prod) do
    type = Map.get(prod, :type, Map.get(prod, "type", "unknown"))

    inspect(prod, pretty: true, limit: 200, width: 80)
    |> String.slice(0, 500)
    |> then(fn text -> "#{type}\n#{text}" end)
  end

  defp inspect_production(prod), do: inspect(prod, pretty: true, limit: 200)
end
