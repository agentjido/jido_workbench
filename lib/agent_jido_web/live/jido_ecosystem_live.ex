defmodule AgentJidoWeb.JidoEcosystemLive do
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts
  import AgentJidoWeb.Jido.MarketingCards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, selected_layer: :all)}
  end

  @impl true
  def handle_event("filter_layer", %{"layer" => layer}, socket) do
    {:noreply, assign(socket, selected_layer: String.to_existing_atom(layer))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/ecosystem">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <%!-- Hero Section --%>
        <section class="mb-12">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              PACKAGE ECOSYSTEM
            </span>
          </div>

          <h1 class="text-3xl font-bold leading-tight mb-4 tracking-tight">
            Most agent frameworks are monoliths.<br />
            <span class="text-primary">Jido is composable.</span>
          </h1>

          <p class="text-sm text-secondary-foreground leading-relaxed max-w-[600px] mb-6">
            Use the full stack or pick the packages you need. Foundation packages for LLM handling,
            core framework for autonomy, and specialized packages for AI and coding workflows.
          </p>

          <%!-- Quick Stats --%>
          <div class="flex gap-6 mb-8">
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">7</span>
              <span class="text-muted-foreground text-xs">packages</span>
            </div>
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">4</span>
              <span class="text-muted-foreground text-xs">layers</span>
            </div>
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">0</span>
              <span class="text-muted-foreground text-xs">forced deps</span>
            </div>
          </div>
        </section>

        <%!-- Dependency Graph --%>
        <section class="mb-16">
          <div class="flex justify-between items-center mb-5">
            <span class="text-sm font-bold tracking-wider">DEPENDENCY GRAPH</span>
            <span class="text-[11px] text-muted-foreground">packages compose bottom-up</span>
          </div>

          <div class="code-block overflow-hidden">
            <div class="code-header">
              <div class="flex gap-2">
                <span class="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
                <span class="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
                <span class="w-2.5 h-2.5 rounded-full bg-primary"></span>
              </div>
              <span class="text-[10px] text-muted-foreground">dependency_graph.txt</span>
            </div>
            <div class="p-6 overflow-x-auto">
              <pre class="text-[11px] leading-relaxed whitespace-pre"><%= dependency_graph_ascii() %></pre>
            </div>
          </div>
        </section>

        <%!-- Filter Section --%>
        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">ALL PACKAGES</span>
            <div class="flex flex-wrap gap-2">
              <button
                phx-click="filter_layer"
                phx-value-layer="all"
                class={"px-4 py-2 text-[11px] rounded transition-colors #{if @selected_layer == :all, do: "bg-primary/10 border border-primary text-primary font-semibold", else: "border border-border text-muted-foreground hover:text-foreground"}"}
              >
                ALL
              </button>
              <button
                phx-click="filter_layer"
                phx-value-layer="foundation"
                class={"px-4 py-2 text-[11px] rounded transition-colors #{if @selected_layer == :foundation, do: "bg-accent-cyan/10 border border-accent-cyan text-accent-cyan font-semibold", else: "border border-border text-muted-foreground hover:text-foreground"}"}
              >
                FOUNDATION
              </button>
              <button
                phx-click="filter_layer"
                phx-value-layer="core"
                class={"px-4 py-2 text-[11px] rounded transition-colors #{if @selected_layer == :core, do: "bg-primary/10 border border-primary text-primary font-semibold", else: "border border-border text-muted-foreground hover:text-foreground"}"}
              >
                CORE
              </button>
              <button
                phx-click="filter_layer"
                phx-value-layer="ai"
                class={"px-4 py-2 text-[11px] rounded transition-colors #{if @selected_layer == :ai, do: "bg-accent-yellow/10 border border-accent-yellow text-accent-yellow font-semibold", else: "border border-border text-muted-foreground hover:text-foreground"}"}
              >
                AI
              </button>
              <button
                phx-click="filter_layer"
                phx-value-layer="app"
                class={"px-4 py-2 text-[11px] rounded transition-colors #{if @selected_layer == :app, do: "bg-accent-red/10 border border-accent-red text-accent-red font-semibold", else: "border border-border text-muted-foreground hover:text-foreground"}"}
              >
                APPLICATION
              </button>
            </div>
          </div>

          <%!-- Package Grid --%>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for pkg <- filtered_packages(@selected_layer) do %>
              <.package_card
                name={pkg.name}
                desc={pkg.desc}
                layer={pkg.layer}
                links={pkg.links}
              />
            <% end %>
          </div>
        </section>

        <%!-- CTA Section --%>
        <section class="mb-16">
          <div class="cta-glow rounded-lg p-12 text-center">
            <h2 class="text-2xl font-bold mb-3">Ready to build?</h2>
            <p class="text-secondary-foreground text-sm mb-6">
              Start with the getting started guide or explore production examples.
            </p>
            <div class="flex gap-3 justify-center">
              <.link
                navigate="/getting-started"
                class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-3 rounded transition-colors"
              >
                GET STARTED →
              </.link>
              <.link
                navigate="/examples"
                class="border border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10 text-[13px] font-medium px-7 py-3 rounded transition-colors"
              >
                VIEW EXAMPLES
              </.link>
            </div>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  defp dependency_graph_ascii do
    Phoenix.HTML.raw("""
                              ┌─────────────────┐
                              │ <span class="text-accent-red">jido_coder</span>    │  ◀── AI coding workflows
                              │ <span class="text-muted-foreground">file ops, git</span>  │
                              └────────┬────────┘
                                       │
                              ┌────────▼────────┐
                              │    <span class="text-accent-yellow">jido_ai</span>     │  ◀── LLM-powered agents
                              │ <span class="text-muted-foreground">token tracking</span> │
                              └────────┬────────┘
                     ┌─────────────────┼─────────────────┐
                     │                 │                 │
              ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
              │    <span class="text-accent-green">jido</span>    │   │<span class="text-accent-green">jido_action</span> │   │<span class="text-accent-green">jido_signal</span> │
              │ <span class="text-muted-foreground">bot core</span>   │   │ <span class="text-muted-foreground">validation</span> │   │ <span class="text-muted-foreground">pub/sub</span>    │
              └──────┬──────┘   └─────────────┘   └─────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
    ┌──────▼──────┐          ┌───────▼──────┐
    │  <span class="text-accent-cyan">req_llm</span>   │          │    <span class="text-accent-cyan">llmdb</span>    │
    │ <span class="text-muted-foreground">HTTP client</span>│          │ <span class="text-muted-foreground">model registry</span>│
    └─────────────┘          └──────────────┘
    """)
  end

  defp filtered_packages(:all), do: packages()
  defp filtered_packages(layer), do: Enum.filter(packages(), &(&1.layer == layer))

  defp packages do
    [
      %{
        name: "llmdb",
        desc: "Model registry and metadata. Token limits, pricing, capabilities for OpenAI, Anthropic, Google, and custom providers.",
        layer: :foundation,
        links: %{"hex" => "https://hex.pm/packages/llmdb", "docs" => "/docs/packages/llmdb", "github" => "https://github.com/agentjido/llmdb"}
      },
      %{
        name: "req_llm",
        desc: "HTTP client for LLM APIs. Built on Req with automatic retries, rate limiting, streaming, and function calling.",
        layer: :foundation,
        links: %{"hex" => "https://hex.pm/packages/req_llm", "docs" => "/docs/packages/req-llm", "github" => "https://github.com/agentjido/req_llm"}
      },
      %{
        name: "jido",
        desc: "BEAM-native bot framework. OTP supervision, isolated processes, message-passing. Run 10k+ agents per node.",
        layer: :core,
        links: %{"hex" => "https://hex.pm/packages/jido", "docs" => "/docs/packages/jido", "github" => "https://github.com/agentjido/jido"}
      },
      %{
        name: "jido_action",
        desc: "Schema-based action validation. Required fields, defaults, type constraints. Composable action primitives.",
        layer: :core,
        links: %{
          "hex" => "https://hex.pm/packages/jido_action",
          "docs" => "/docs/packages/jido-action",
          "github" => "https://github.com/agentjido/jido"
        }
      },
      %{
        name: "jido_signal",
        desc: "Pub/sub signaling between agents. Decoupled coordination via BEAM message-passing. No external broker.",
        layer: :core,
        links: %{
          "hex" => "https://hex.pm/packages/jido_signal",
          "docs" => "/docs/packages/jido-signal",
          "github" => "https://github.com/agentjido/jido"
        }
      },
      %{
        name: "jido_ai",
        desc: "LLM-powered agents with token/cost tracking, tool calling, and streaming. Integrates jido + req_llm + llmdb.",
        layer: :ai,
        links: %{"hex" => "https://hex.pm/packages/jido_ai", "docs" => "/docs/packages/jido-ai", "github" => "https://github.com/agentjido/jido_ai"}
      },
      %{
        name: "jido_coder",
        desc: "AI coding agent with file operations, git integration, code analysis, and test execution workflows.",
        layer: :app,
        links: %{
          "hex" => "https://hex.pm/packages/jido_coder",
          "docs" => "/docs/packages/jido-coder",
          "github" => "https://github.com/agentjido/jido_coder"
        }
      }
    ]
  end
end
