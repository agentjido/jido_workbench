defmodule AgentJidoWeb.Examples.RunicStructuredBranchingLive do
  @moduledoc """
  Interactive demo for deterministic Runic structured branching workflows.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.RunicStructuredBranching.RuntimeDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :demo, RuntimeDemo.new())}
  end

  @impl true
  def render(assigns) do
    ordered_phase_1_nodes = ordered_nodes(assigns.demo.phase_1_graph, RuntimeDemo.phase_1_order())
    ordered_phase_2_nodes = ordered_nodes(assigns.demo.phase_2_graph, RuntimeDemo.phase_2_order(assigns.demo.selected_workflow))

    assigns =
      assigns
      |> assign(:ordered_phase_1_nodes, ordered_phase_1_nodes)
      |> assign(:ordered_phase_2_nodes, ordered_phase_2_nodes)

    ~H"""
    <div id="runic-structured-branching-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Runic Structured LLM Branching</div>
          <div class="text-[11px] text-muted-foreground">
            Real deterministic `runic.set_workflow` routing with direct, analysis, and safe branch DAGs
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          status: {@demo.status}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Selected Route</div>
          <div id="runic-branching-selected-branch" class="text-sm font-semibold text-foreground mt-2">
            {if @demo.selected_branch, do: @demo.selected_branch, else: "pending"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Workflow</div>
          <div id="runic-branching-selected-workflow" class="text-sm font-semibold text-foreground mt-2">
            {if @demo.selected_workflow, do: @demo.selected_workflow, else: "phase_1_route"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Confidence</div>
          <div id="runic-branching-confidence" class="text-sm font-semibold text-foreground mt-2">
            {format_confidence(@demo.decision)}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Executed Nodes</div>
          <div id="runic-branching-executions" class="text-sm font-semibold text-foreground mt-2">
            {length(@demo.executions)}
          </div>
        </div>
      </div>

      <div class="space-y-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Question presets</div>
        <div class="flex gap-2 flex-wrap">
          <%= for prompt <- RuntimeDemo.prompts() do %>
            <button
              phx-click="select_prompt"
              phx-value-prompt={prompt.id}
              class={"px-3 py-2 rounded-md border text-xs transition-colors #{prompt_button_class(@demo.selected_prompt_id == prompt.id)}"}
            >
              {prompt.title}
            </button>
          <% end %>
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Selected Question</div>
        <div id="runic-branching-question" class="text-sm font-semibold text-foreground">{@demo.selected_prompt.question}</div>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="runic-branching-run-btn"
          phx-click="run_workflow"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run Branch Workflow
        </button>
        <button
          id="runic-branching-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[0.95fr_1.05fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Route Decision</div>

            <div :if={is_nil(@demo.decision)} class="text-xs text-muted-foreground">
              Run the selected question to inspect the structured route, confidence, and reasoning payload.
            </div>

            <div :if={@demo.decision} class="space-y-3">
              <div class="grid gap-3 sm:grid-cols-3">
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Route</div>
                  <div class="text-sm font-semibold text-foreground mt-1">{@demo.decision.route}</div>
                </div>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Detail Level</div>
                  <div class="text-sm font-semibold text-foreground mt-1">{@demo.decision.detail_level}</div>
                </div>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Confidence</div>
                  <div class="text-sm font-semibold text-foreground mt-1">{format_confidence(@demo.decision)}</div>
                </div>
              </div>
              <div class="rounded-md border border-border bg-background/70 p-3">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Reasoning</div>
                <div id="runic-branching-reasoning" class="text-[11px] text-foreground mt-2 whitespace-pre-wrap">
                  {@demo.decision.reasoning}
                </div>
              </div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Phase 1 Routing DAG</div>
              <div class="text-[10px] text-muted-foreground">{length(@ordered_phase_1_nodes)} node(s)</div>
            </div>

            <div id="runic-branching-phase-1-graph" class="space-y-2">
              <%= for node <- @ordered_phase_1_nodes do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-xs font-semibold text-foreground">{node.name}</div>
                      <div class="text-[11px] text-muted-foreground mt-1">{inspect(node.action_mod)}</div>
                    </div>
                    <div class={"text-[10px] uppercase tracking-wider #{node_status_class(node.status)}"}>
                      {node.status}
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Phase 2 Branch DAG</div>
              <div class="text-[10px] text-muted-foreground">
                {if @demo.selected_workflow, do: @demo.selected_workflow, else: "awaiting selection"}
              </div>
            </div>

            <div :if={@ordered_phase_2_nodes == []} class="text-xs text-muted-foreground">
              The phase-2 branch graph appears after the route decision selects a workflow.
            </div>

            <div :if={@ordered_phase_2_nodes != []} id="runic-branching-phase-2-graph" class="space-y-2">
              <%= for node <- @ordered_phase_2_nodes do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-xs font-semibold text-foreground">{node.name}</div>
                      <div class="text-[11px] text-muted-foreground mt-1">{inspect(node.action_mod)}</div>
                    </div>
                    <div class={"text-[10px] uppercase tracking-wider #{node_status_class(node.status)}"}>
                      {node.status}
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Branch Result</div>
            <pre id="runic-branching-result" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.branch_result == "", do: "Run the workflow to inspect the selected branch result.", else: @demo.branch_result %></pre>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Takeaway</div>
            <div id="runic-branching-takeaway" class="text-[11px] text-foreground whitespace-pre-wrap">
              {if @demo.takeaway == "", do: "The branch-specific takeaway appears after the phase-2 workflow completes.", else: @demo.takeaway}
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Execution Log</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.executions)} entry(s)</div>
            </div>

            <div :if={@demo.executions == []} class="text-xs text-muted-foreground">
              Each executed node records its workflow, input payload, and result here.
            </div>

            <div :if={@demo.executions != []} id="runic-branching-log" class="space-y-3 max-h-[28rem] overflow-y-auto">
              <%= for entry <- @demo.executions do %>
                <div class="rounded-md border border-border bg-background/70 p-3 space-y-2">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-xs font-semibold text-foreground">{entry.node}</div>
                      <div class="text-[10px] uppercase tracking-wider text-muted-foreground mt-1">{entry.workflow}</div>
                    </div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground">{entry.status}</div>
                  </div>
                  <div class="grid gap-2 lg:grid-cols-2">
                    <div>
                      <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">Input</div>
                      <pre class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= inspect(entry.input, pretty: true, width: 70) %></pre>
                    </div>
                    <div>
                      <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">Output</div>
                      <pre class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= inspect(entry.output, pretty: true, width: 70) %></pre>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Activity</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.log)} note(s)</div>
            </div>
            <div class="space-y-2 max-h-[18rem] overflow-y-auto">
              <%= for entry <- @demo.log do %>
                <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                  <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
                  <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select_prompt", %{"prompt" => prompt_id}, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.select_prompt(socket.assigns.demo, prompt_id))}
  end

  def handle_event("run_workflow", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.run(socket.assigns.demo))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.reset(socket.assigns.demo))}
  end

  defp ordered_nodes(graph, order) do
    order_index = order |> Enum.with_index() |> Map.new()

    graph.nodes
    |> Enum.sort_by(fn node -> Map.get(order_index, node.name, 999) end)
  end

  defp prompt_button_class(true), do: "border-primary/40 bg-primary/10 text-primary"
  defp prompt_button_class(false), do: "border-border bg-elevated text-muted-foreground hover:text-foreground hover:border-primary/30"

  defp format_confidence(nil), do: "pending"
  defp format_confidence(decision), do: :erlang.float_to_binary(decision.confidence, decimals: 2)

  defp node_status_class(:completed), do: "text-emerald-300"
  defp node_status_class(:pending), do: "text-amber-300"
  defp node_status_class(:failed), do: "text-red-300"
  defp node_status_class(:idle), do: "text-muted-foreground"
  defp node_status_class(:waiting), do: "text-accent-cyan"
  defp node_status_class(_other), do: "text-muted-foreground"
end
