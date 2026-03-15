defmodule AgentJidoWeb.Examples.RunicAdaptiveResearcherLive do
  @moduledoc """
  Interactive demo for deterministic Runic adaptive researcher workflows.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.RunicAdaptiveResearcher.{OrchestratorAgent, RuntimeDemo}

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
    <div id="runic-adaptive-researcher-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Runic Adaptive Researcher</div>
          <div class="text-[11px] text-muted-foreground">
            Real deterministic phase selection with `runic.set_workflow` swapping between full and slim writing DAGs
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          status: {@demo.status}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Phase 2</div>
          <div id="runic-adaptive-selected-phase" class="text-sm font-semibold text-foreground mt-2">
            {if @demo.phase_2_type, do: @demo.phase_2_type, else: "pending"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Workflow</div>
          <div id="runic-adaptive-selected-workflow" class="text-sm font-semibold text-foreground mt-2">
            {if @demo.selected_workflow, do: @demo.selected_workflow, else: "phase_1_research"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Summary Length</div>
          <div id="runic-adaptive-summary-length" class="text-sm font-semibold text-foreground mt-2">
            {@demo.summary_length}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Threshold</div>
          <div id="runic-adaptive-threshold" class="text-sm font-semibold text-foreground mt-2">
            {OrchestratorAgent.rich_threshold()}
          </div>
        </div>
      </div>

      <div class="space-y-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Topic presets</div>
        <div class="flex gap-2 flex-wrap">
          <%= for topic <- RuntimeDemo.topics() do %>
            <button
              phx-click="select_topic"
              phx-value-topic={topic.id}
              class={"px-3 py-2 rounded-md border text-xs transition-colors #{topic_button_class(@demo.selected_topic_id == topic.id)}"}
            >
              {topic.title}
            </button>
          <% end %>
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Selected Topic</div>
        <div id="runic-adaptive-topic" class="text-sm font-semibold text-foreground">{@demo.selected_topic.title}</div>
        <div class="text-[11px] text-muted-foreground mt-2">
          {Enum.join(@demo.selected_topic.queries, " · ")}
        </div>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="runic-adaptive-run-btn"
          phx-click="run_workflow"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run Adaptive Workflow
        </button>
        <button
          id="runic-adaptive-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[0.95fr_1.05fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Phase Selection</div>

            <div :if={is_nil(@demo.phase_2_type)} class="text-xs text-muted-foreground">
              Run the selected topic to inspect the research summary length and chosen phase-2 workflow.
            </div>

            <div :if={@demo.phase_2_type} class="space-y-3">
              <div class="grid gap-3 sm:grid-cols-3">
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Summary Length</div>
                  <div class="text-sm font-semibold text-foreground mt-1">{@demo.summary_length}</div>
                </div>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Threshold</div>
                  <div class="text-sm font-semibold text-foreground mt-1">{OrchestratorAgent.rich_threshold()}</div>
                </div>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Selected Phase</div>
                  <div class="text-sm font-semibold text-foreground mt-1">{@demo.phase_2_type}</div>
                </div>
              </div>
              <div class="rounded-md border border-border bg-background/70 p-3">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Why This Phase</div>
                <div id="runic-adaptive-phase-note" class="text-[11px] text-foreground mt-2 whitespace-pre-wrap">
                  {phase_note(@demo.phase_2_type)}
                </div>
              </div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Phase 1 Research DAG</div>
              <div class="text-[10px] text-muted-foreground">{length(@ordered_phase_1_nodes)} node(s)</div>
            </div>

            <div id="runic-adaptive-phase-1-graph" class="space-y-2">
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
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Phase 2 Writing DAG</div>
              <div class="text-[10px] text-muted-foreground">
                {if @demo.selected_workflow, do: @demo.selected_workflow, else: "awaiting selection"}
              </div>
            </div>

            <div :if={@ordered_phase_2_nodes == []} class="text-xs text-muted-foreground">
              The adaptive phase-2 graph appears after the research results select the next workflow.
            </div>

            <div :if={@ordered_phase_2_nodes != []} id="runic-adaptive-phase-2-graph" class="space-y-2">
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
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Article Output</div>
            <pre id="runic-adaptive-article" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.article_markdown == "", do: "Run the adaptive workflow to inspect the final article artifact.", else: @demo.article_markdown %></pre>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Takeaway</div>
            <div id="runic-adaptive-takeaway" class="text-[11px] text-foreground whitespace-pre-wrap">
              {if @demo.takeaway == "", do: "The adaptive takeaway appears after the writing workflow completes.", else: @demo.takeaway}
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

            <div :if={@demo.executions != []} id="runic-adaptive-log" class="space-y-3 max-h-[28rem] overflow-y-auto">
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
  def handle_event("select_topic", %{"topic" => topic_id}, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.select_topic(socket.assigns.demo, topic_id))}
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

  defp phase_note(:full) do
    "The research summary crossed the richness threshold, so the workflow keeps the BuildOutline stage before drafting."
  end

  defp phase_note(:slim) do
    "The research summary stayed below the richness threshold, so the workflow skips BuildOutline and drafts directly."
  end

  defp phase_note(_other), do: "Phase selection appears after the phase-1 research run completes."

  defp topic_button_class(true), do: "border-primary/40 bg-primary/10 text-primary"
  defp topic_button_class(false), do: "border-border bg-elevated text-muted-foreground hover:text-foreground hover:border-primary/30"

  defp node_status_class(:completed), do: "text-emerald-300"
  defp node_status_class(:pending), do: "text-amber-300"
  defp node_status_class(:failed), do: "text-red-300"
  defp node_status_class(:idle), do: "text-muted-foreground"
  defp node_status_class(:waiting), do: "text-accent-cyan"
  defp node_status_class(_other), do: "text-muted-foreground"
end
