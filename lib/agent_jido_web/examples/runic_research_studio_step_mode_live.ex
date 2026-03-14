defmodule AgentJidoWeb.Examples.RunicResearchStudioStepModeLive do
  @moduledoc """
  Step-mode interactive demo for the deterministic Runic research studio workflow.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.RunicResearchStudio.RuntimeDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :demo, RuntimeDemo.new(:step))}
  end

  @impl true
  def render(assigns) do
    ordered_nodes = ordered_nodes(assigns.demo)
    assigns = assign(assigns, :ordered_nodes, ordered_nodes)

    ~H"""
    <div id="runic-research-studio-step-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Runic AI Research Studio Step Mode</div>
          <div class="text-[11px] text-muted-foreground">
            Real `runic.step` and `runic.resume` transitions over the deterministic research DAG
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          status: {@demo.status}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Mode</div>
          <div id="runic-step-mode" class="text-sm font-semibold text-foreground mt-2">
            {@demo.execution_mode}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Held Nodes</div>
          <div id="runic-step-held-count" class="text-sm font-semibold text-foreground mt-2">
            {@demo.held_count}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Step History</div>
          <div id="runic-step-history-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@demo.step_history)}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Productions</div>
          <div id="runic-step-productions" class="text-sm font-semibold text-foreground mt-2">
            {length(@demo.productions)}
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

      <div class="flex gap-3 flex-wrap">
        <button
          id="runic-step-prepare-btn"
          phx-click="prepare_step"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Prepare Step Mode
        </button>
        <button
          id="runic-step-next-btn"
          phx-click="step_once"
          class="px-4 py-2 rounded-md bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan hover:bg-accent-cyan/20 transition-colors text-sm font-semibold"
        >
          Step Once
        </button>
        <button
          id="runic-step-resume-btn"
          phx-click="resume_demo"
          class="px-4 py-2 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/20 transition-colors text-sm font-semibold"
        >
          Resume to Completion
        </button>
        <button
          id="runic-step-reset-btn"
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
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Held Runnables</div>
              <div class="text-[10px] text-muted-foreground">{@demo.held_count} held</div>
            </div>

            <div :if={@demo.held_nodes == []} class="text-xs text-muted-foreground">
              Prepare step mode to hold the first runnable batch, or resume to drain the workflow.
            </div>

            <div :if={@demo.held_nodes != []} id="runic-step-held-nodes" class="flex gap-2 flex-wrap">
              <%= for node <- @demo.held_nodes do %>
                <span class="text-[10px] px-2 py-1 rounded bg-primary/10 border border-primary/30 text-primary">
                  {node}
                </span>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Workflow Graph</div>
              <div class="text-[10px] text-muted-foreground">{@demo.summary.total_nodes} node(s)</div>
            </div>

            <div id="runic-step-graph" class="space-y-2">
              <%= for node <- @ordered_nodes do %>
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
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Step History</div>

            <div :if={@demo.executions == []} class="text-xs text-muted-foreground">
              Each call to `runic.step` or `runic.resume` records real node input/output details here.
            </div>

            <div :if={@demo.executions != []} id="runic-step-log" class="space-y-3 max-h-[28rem] overflow-y-auto">
              <%= for entry <- @demo.executions do %>
                <div class="rounded-md border border-border bg-background/70 p-3 space-y-2">
                  <div class="flex items-center justify-between gap-3">
                    <div class="text-xs font-semibold text-foreground">{entry.node}</div>
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
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Selected Topic</div>
            <div id="runic-step-topic" class="text-sm font-semibold text-foreground">{@demo.selected_topic.title}</div>
            <div class="text-[11px] text-muted-foreground mt-2">
              {Enum.join(@demo.selected_topic.outline_seed, " · ")}
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Editorial Takeaway</div>
            <div id="runic-step-takeaway" class="text-[11px] text-foreground whitespace-pre-wrap">
              {if @demo.takeaway == "", do: "The takeaway appears when the final node completes.", else: @demo.takeaway}
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Article Output</div>
            <pre id="runic-step-article" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.article_markdown == "", do: "Step through the workflow or resume it to inspect the final article artifact.", else: @demo.article_markdown %></pre>
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

  def handle_event("prepare_step", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.prepare_step(socket.assigns.demo))}
  end

  def handle_event("step_once", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.step(socket.assigns.demo))}
  end

  def handle_event("resume_demo", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.resume(socket.assigns.demo))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.reset(socket.assigns.demo))}
  end

  defp ordered_nodes(demo) do
    order_index = RuntimeDemo.pipeline_order() |> Enum.with_index() |> Map.new()

    demo.graph.nodes
    |> Enum.sort_by(fn node -> Map.get(order_index, node.name, 999) end)
  end

  defp topic_button_class(true), do: "border-primary/40 bg-primary/10 text-primary"
  defp topic_button_class(false), do: "border-border bg-elevated text-muted-foreground hover:text-foreground hover:border-primary/30"

  defp node_status_class(:completed), do: "text-emerald-300"
  defp node_status_class(:pending), do: "text-amber-300"
  defp node_status_class(:failed), do: "text-red-300"
  defp node_status_class(:idle), do: "text-muted-foreground"
  defp node_status_class(:waiting), do: "text-accent-cyan"
  defp node_status_class(_other), do: "text-muted-foreground"
end
