defmodule AgentJidoWeb.Examples.RunicDelegatingOrchestratorLive do
  @moduledoc """
  Interactive demo for deterministic Runic delegation workflows.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.RunicDelegatingOrchestrator.RuntimeDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :demo, RuntimeDemo.new())}
  end

  @impl true
  def render(assigns) do
    ordered_nodes = ordered_nodes(assigns.demo.graph)
    assigns = assign(assigns, :ordered_nodes, ordered_nodes)

    ~H"""
    <div id="runic-delegating-orchestrator-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Runic Delegating Orchestrator</div>
          <div class="text-[11px] text-muted-foreground">
            Real deterministic parent and child-worker handoffs for delegated drafting and editing stages
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          status: {@demo.status}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Local Nodes</div>
          <div id="runic-delegating-local-count" class="text-sm font-semibold text-foreground mt-2">
            {length(RuntimeDemo.completed_local_nodes(@demo))}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Delegated Nodes</div>
          <div id="runic-delegating-delegated-count" class="text-sm font-semibold text-foreground mt-2">
            {length(RuntimeDemo.completed_child_tags(@demo))}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Handoff Events</div>
          <div id="runic-delegating-handoff-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@demo.handoffs)}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Executed Nodes</div>
          <div id="runic-delegating-execution-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@demo.executions)}
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
        <div id="runic-delegating-topic" class="text-sm font-semibold text-foreground">{@demo.selected_topic.title}</div>
        <div class="text-[11px] text-muted-foreground mt-2">
          Delegated nodes: `draft_article -> child:drafter`, `edit_and_assemble -> child:editor`
        </div>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="runic-delegating-run-btn"
          phx-click="run_workflow"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run Delegating Workflow
        </button>
        <button
          id="runic-delegating-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[0.95fr_1.05fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Workflow Graph</div>
              <div class="text-[10px] text-muted-foreground">{length(@ordered_nodes)} node(s)</div>
            </div>

            <div id="runic-delegating-graph" class="space-y-2">
              <%= for node <- @ordered_nodes do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-xs font-semibold text-foreground">{node.name}</div>
                      <div class="text-[11px] text-muted-foreground mt-1">{inspect(node.action_mod)}</div>
                      <div class="text-[10px] text-muted-foreground mt-1">{executor_label(node)}</div>
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
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Child Handoffs</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.handoffs)} event(s)</div>
            </div>

            <div :if={@demo.handoffs == []} class="text-xs text-muted-foreground">
              Run the workflow to inspect child assignment, child start, and child completion events.
            </div>

            <div :if={@demo.handoffs != []} id="runic-delegating-handoffs" class="space-y-2 max-h-[24rem] overflow-y-auto">
              <%= for entry <- @demo.handoffs do %>
                <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                  <div class="text-[11px] font-semibold text-foreground">{entry.node} -> {entry.tag}</div>
                  <div class="text-[11px] text-muted-foreground">
                    {entry.state} via {inspect(entry.child_module)}
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Article Output</div>
            <pre id="runic-delegating-article" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.article_markdown == "", do: "Run the workflow to inspect the delegated article artifact.", else: @demo.article_markdown %></pre>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Takeaway</div>
            <div id="runic-delegating-takeaway" class="text-[11px] text-foreground whitespace-pre-wrap">
              {if @demo.takeaway == "", do: "The editorial takeaway appears after the delegated workflow completes.", else: @demo.takeaway}
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Execution Log</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.executions)} entry(s)</div>
            </div>

            <div :if={@demo.executions == []} class="text-xs text-muted-foreground">
              Each local or delegated runnable records its input and output here.
            </div>

            <div :if={@demo.executions != []} id="runic-delegating-log" class="space-y-3 max-h-[28rem] overflow-y-auto">
              <%= for entry <- @demo.executions do %>
                <div class="rounded-md border border-border bg-background/70 p-3 space-y-2">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-xs font-semibold text-foreground">{entry.node}</div>
                      <div class="text-[10px] uppercase tracking-wider text-muted-foreground mt-1">{target_label(entry.target)}</div>
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

  defp ordered_nodes(graph) do
    order_index = RuntimeDemo.pipeline_order() |> Enum.with_index() |> Map.new()

    graph.nodes
    |> Enum.sort_by(fn node -> Map.get(order_index, node.name, 999) end)
  end

  defp executor_label(%{executor: {:child, tag}}), do: "executor: child #{tag}"
  defp executor_label(%{executor: {:child, tag, _spec}}), do: "executor: child #{tag}"
  defp executor_label(_node), do: "executor: local"

  defp target_label(:local), do: "local"
  defp target_label({:child, tag}), do: "child #{tag}"

  defp topic_button_class(true), do: "border-primary/40 bg-primary/10 text-primary"
  defp topic_button_class(false), do: "border-border bg-elevated text-muted-foreground hover:text-foreground hover:border-primary/30"

  defp node_status_class(:completed), do: "text-emerald-300"
  defp node_status_class(:pending), do: "text-amber-300"
  defp node_status_class(:failed), do: "text-red-300"
  defp node_status_class(:idle), do: "text-muted-foreground"
  defp node_status_class(:waiting), do: "text-accent-cyan"
  defp node_status_class(_other), do: "text-muted-foreground"
end
