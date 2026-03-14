defmodule AgentJidoWeb.Examples.SkillsMultiAgentOrchestrationLive do
  @moduledoc """
  Interactive multi-skill orchestration demo backed by deterministic local specialists.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.SkillsMultiAgentOrchestration.Orchestrator

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_demo(socket, Orchestrator.new())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="skills-multi-agent-orchestration-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Skills Multi-Agent Orchestration</div>
          <div class="text-[11px] text-muted-foreground">
            Real deterministic routing across module-backed and file-backed specialist skills
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          registry: {@registry_count} skill(s)
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">File Skills</div>
          <div class="text-sm font-semibold text-foreground mt-2">{@demo.loaded_count}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Module Skills</div>
          <div class="text-sm font-semibold text-foreground mt-2">{@registry_count - @demo.loaded_count}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Last Route</div>
          <div id="skills-orchestration-last-route" class="text-sm font-semibold text-foreground mt-2">
            {if @demo.last_run, do: @demo.last_run.label, else: "idle"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Prompt Ready</div>
          <div class="text-sm font-semibold text-foreground mt-2">
            {if @demo.last_run && @demo.last_run.prompt != "", do: "yes", else: "no"}
          </div>
        </div>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="skills-run-arithmetic-btn"
          phx-click="run_arithmetic"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run Arithmetic
        </button>
        <button
          id="skills-run-conversion-btn"
          phx-click="run_conversion"
          class="px-4 py-2 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/20 transition-colors text-sm font-semibold"
        >
          Run Conversion
        </button>
        <button
          id="skills-run-combined-btn"
          phx-click="run_combined"
          class="px-4 py-2 rounded-md bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan hover:bg-accent-cyan/20 transition-colors text-sm font-semibold"
        >
          Run Combined Request
        </button>
        <button
          id="skills-orchestration-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1.05fr_0.95fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Specialist Registry</div>
              <div class="text-[10px] text-muted-foreground">{@registry_count} skill(s)</div>
            </div>

            <div id="skills-orchestration-registry" class="space-y-2">
              <%= for spec <- @demo.registry_specs do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-xs font-semibold text-foreground">{spec.name}</div>
                  <div class="text-[11px] text-muted-foreground mt-1">{spec.description}</div>
                  <div class="text-[11px] text-muted-foreground mt-2">
                    tools: {Enum.join(spec.allowed_tools, ", ")}
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Route Decision</div>

            <div :if={is_nil(@demo.last_run)} class="text-xs text-muted-foreground">
              Run one of the fixed requests to inspect the router decision and selected specialists.
            </div>

            <div :if={@demo.last_run} id="skills-route-decision" class="space-y-3">
              <div class="text-[11px] text-foreground">
                <span class="font-semibold">question:</span> {@demo.last_run.question}
              </div>
              <div class="text-[11px] text-muted-foreground">{@demo.last_run.route}</div>
              <div class="flex gap-2 flex-wrap">
                <%= for spec <- @demo.last_run.selected_skills do %>
                  <span class="text-[10px] px-2 py-1 rounded bg-primary/10 border border-primary/30 text-primary">
                    {spec.name}
                  </span>
                <% end %>
              </div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Selected Prompt</div>
            <pre id="skills-selected-prompt" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.last_run, do: @demo.last_run.prompt, else: "Prompt output appears after a routed request." %></pre>
          </div>
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Tool Trace</div>

            <div :if={is_nil(@demo.last_run)} class="text-xs text-muted-foreground">
              No orchestration steps have executed yet.
            </div>

            <div :if={@demo.last_run} id="skills-tool-trace" class="space-y-2">
              <%= for step <- @demo.last_run.tool_trace do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-[11px] font-semibold text-foreground">{step.tool}</div>
                  <div class="text-[11px] text-muted-foreground mt-1">input: {step.input}</div>
                  <div class="text-[11px] text-foreground mt-1">output: {step.output}</div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Response</div>
            <div id="skills-orchestration-response" class="text-[11px] text-foreground whitespace-pre-wrap">
              {if @demo.last_run, do: @demo.last_run.response, else: "Run a request to inspect the final response."}
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">History</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.history)} event(s)</div>
            </div>

            <div id="skills-orchestration-history" class="space-y-2 max-h-[26rem] overflow-y-auto">
              <%= for entry <- @demo.history do %>
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
  def handle_event("run_arithmetic", _params, socket) do
    {:noreply, assign_demo(socket, Orchestrator.run_scenario(socket.assigns.demo, :arithmetic))}
  end

  def handle_event("run_conversion", _params, socket) do
    {:noreply, assign_demo(socket, Orchestrator.run_scenario(socket.assigns.demo, :conversion))}
  end

  def handle_event("run_combined", _params, socket) do
    {:noreply, assign_demo(socket, Orchestrator.run_scenario(socket.assigns.demo, :combined))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign_demo(socket, Orchestrator.reset(socket.assigns.demo))}
  end

  defp assign_demo(socket, demo) do
    assign(socket,
      demo: demo,
      registry_count: length(demo.registry_specs)
    )
  end
end
