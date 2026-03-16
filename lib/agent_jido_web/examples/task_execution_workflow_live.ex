defmodule AgentJidoWeb.Examples.TaskExecutionWorkflowLive do
  @moduledoc """
  Interactive task lifecycle demo backed by the shipped task-list actions.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.TaskExecution.Workflow

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :workflow, Workflow.new())}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :summary, assigns.workflow.state.summary)

    ~H"""
    <div id="task-execution-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Task Execution Workflow</div>
          <div class="text-[11px] text-muted-foreground">
            Real task lifecycle transitions through `tasklist_*` actions with local deterministic state
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          next: {render_next_status(@workflow.next.status)}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Pending</div>
          <div id="task-pending-count" class="text-lg font-bold text-foreground mt-1">
            {@summary.pending}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">In Progress</div>
          <div id="task-in-progress-count" class="text-lg font-bold text-foreground mt-1">
            {@summary.in_progress}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Done</div>
          <div id="task-done-count" class="text-lg font-bold text-foreground mt-1">
            {@summary.done}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">All Complete</div>
          <div id="task-all-complete" class="text-sm font-semibold text-foreground mt-2">
            {if @workflow.state.all_complete, do: "yes", else: "no"}
          </div>
        </div>
      </div>

      <div
        :if={@workflow.state.all_complete}
        class="rounded-md border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm font-semibold text-emerald-200"
      >
        All {@summary.total} tasks are complete!
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="task-seed-btn"
          phx-click="seed_tasks"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Seed Tasks
        </button>
        <button
          id="task-start-next-btn"
          phx-click="start_next"
          class="px-4 py-2 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/20 transition-colors text-sm font-semibold"
        >
          Start Next Task
        </button>
        <button
          id="task-complete-btn"
          phx-click="complete_active"
          class="px-4 py-2 rounded-md bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan hover:bg-accent-cyan/20 transition-colors text-sm font-semibold"
        >
          Complete Active Task
        </button>
        <button
          id="task-run-full-btn"
          phx-click="run_full_workflow"
          class="px-4 py-2 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-300 hover:bg-amber-500/20 transition-colors text-sm font-semibold"
        >
          Run Full Workflow
        </button>
        <button
          id="task-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1.15fr_0.85fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Current Task State</div>
              <div class="text-[10px] text-muted-foreground">{@summary.total} total task(s)</div>
            </div>

            <div :if={@workflow.tasks == []} class="text-xs text-muted-foreground">
              Seed the workflow to create the release tasks.
            </div>

            <div :if={@workflow.tasks != []} class="space-y-2">
              <%= for task <- @workflow.tasks do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-xs font-semibold text-foreground">{task["title"]}</div>
                      <div class="text-[11px] text-muted-foreground mt-1">{task["description"]}</div>
                    </div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
                      {task["status"]}
                    </div>
                  </div>
                  <div class="mt-2 text-[11px] text-muted-foreground">
                    priority {task["priority"]} · id {String.slice(task["id"], 0, 8)}…
                  </div>
                  <div :if={is_binary(task["result"])} class="mt-2 text-[11px] text-foreground">
                    result: {task["result"]}
                  </div>
                  <div :if={is_binary(task["blocked_reason"])} class="mt-2 text-[11px] text-red-300">
                    blocked: {task["blocked_reason"]}
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Next Task Snapshot</div>
            <pre id="task-next-state" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= inspect(@workflow.next, pretty: true, width: 80) %></pre>
          </div>
        </div>

        <div class="rounded-md border border-border bg-elevated p-4">
          <div class="flex items-center justify-between mb-2">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Lifecycle Log</div>
            <div class="text-[10px] text-muted-foreground">{length(@workflow.log)} event(s)</div>
          </div>

          <div :if={@workflow.log == []} class="text-xs text-muted-foreground">
            Run the workflow to inspect task_started and task_completed transitions.
          </div>

          <div :if={@workflow.log != []} class="space-y-2 max-h-[32rem] overflow-y-auto">
            <%= for entry <- @workflow.log do %>
              <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
                <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("seed_tasks", _params, socket) do
    {:noreply, assign(socket, :workflow, Workflow.seed_tasks(socket.assigns.workflow))}
  end

  def handle_event("start_next", _params, socket) do
    {:noreply, assign(socket, :workflow, Workflow.start_next_task(socket.assigns.workflow))}
  end

  def handle_event("complete_active", _params, socket) do
    {:noreply, assign(socket, :workflow, Workflow.complete_active_task(socket.assigns.workflow))}
  end

  def handle_event("run_full_workflow", _params, socket) do
    {:noreply, assign(socket, :workflow, Workflow.run_to_completion(socket.assigns.workflow))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign(socket, :workflow, Workflow.reset())}
  end

  defp render_next_status("next_task"), do: "pending task ready"
  defp render_next_status("tasks_in_progress"), do: "work in progress"
  defp render_next_status("all_complete"), do: "all complete"
  defp render_next_status("no_tasks"), do: "no tasks"
  defp render_next_status(other), do: to_string(other)
end
