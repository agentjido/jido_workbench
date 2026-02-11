defmodule AgentJidoWeb.JidoExamplesLive do
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, og_image: "https://agentjido.xyz/og/examples.png")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/examples">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <%!-- Hero --%>
        <section class="text-center mb-16">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              EXAMPLES & TUTORIALS
            </span>
          </div>
          <h1 class="text-4xl font-bold mb-4">
            Learn by <span class="text-primary">building</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-2xl mx-auto">
            Complete examples from simple agents to production-ready AI applications.
          </p>
        </section>

        <%!-- Getting Started Examples --%>
        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">GETTING STARTED</span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for example <- getting_started_examples() do %>
              <.example_card example={example} />
            <% end %>
          </div>
        </section>

        <%!-- AI Examples --%>
        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">AI-POWERED AGENTS</span>
            <span class="badge-ai">AI</span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for example <- ai_examples() do %>
              <.example_card example={example} />
            <% end %>
          </div>
        </section>

        <%!-- Production Examples --%>
        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">PRODUCTION PATTERNS</span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for example <- production_examples() do %>
              <.example_card example={example} />
            <% end %>
          </div>
        </section>

        <%!-- CTA --%>
        <section>
          <div class="cta-glow rounded-lg p-12 text-center">
            <h2 class="text-2xl font-bold mb-3">Want to contribute an example?</h2>
            <p class="text-secondary-foreground text-sm mb-6">
              We welcome community contributions. Check out our contributing guide.
            </p>
            <a
              href="https://github.com/agentjido/jido/blob/main/CONTRIBUTING.md"
              target="_blank"
              class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-3 rounded transition-colors inline-block"
            >
              CONTRIBUTING GUIDE →
            </a>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  attr :example, :map, required: true

  defp example_card(assigns) do
    ~H"""
    <div class="feature-card">
      <div class="flex justify-between items-start mb-3">
        <span class="text-lg">{@example.emoji}</span>
        <span class={"badge-#{@example.layer}"}>{String.upcase(to_string(@example.layer))}</span>
      </div>
      <h3 class="font-bold text-[15px] mb-2">{@example.title}</h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@example.desc}</p>
      <div class="flex gap-2">
        <a href={@example.livebook_url} class="text-[10px] px-2 py-1 rounded bg-primary/10 text-primary hover:bg-primary/20 transition-colors">
          Livebook
        </a>
        <a href={@example.github_url} class="text-[10px] px-2 py-1 rounded bg-elevated text-muted-foreground hover:text-foreground transition-colors">
          GitHub
        </a>
      </div>
    </div>
    """
  end

  defp getting_started_examples do
    [
      %{
        emoji: "👋",
        title: "Hello Agent",
        desc: "Your first Jido agent in 5 lines. Covers basic setup and message passing.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "🔄",
        title: "State Machines",
        desc: "Build agents with state transitions. Finite state machine patterns.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "📡",
        title: "Signal & Respond",
        desc: "Pub/sub patterns between agents. Event-driven coordination.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "⚡",
        title: "Action Pipelines",
        desc: "Compose actions into workflows. Validation and error handling.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      }
    ]
  end

  defp ai_examples do
    [
      %{
        emoji: "💬",
        title: "Chat Agent",
        desc: "Multi-turn conversations with memory. Token budget management.",
        layer: :ai,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "🔧",
        title: "Tool Calling",
        desc: "Agents that call tools and functions. Structured outputs.",
        layer: :ai,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "📊",
        title: "Research Agent",
        desc: "Web search, summarization, report generation. Real-world workflow.",
        layer: :ai,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "🤖",
        title: "Multi-Agent",
        desc: "Orchestrate multiple AI agents. Delegation and coordination.",
        layer: :ai,
        livebook_url: "#",
        github_url: "#"
      }
    ]
  end

  defp production_examples do
    [
      %{
        emoji: "📈",
        title: "Supervision Trees",
        desc: "Production supervision strategies. Restart policies and isolation.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "📊",
        title: "Telemetry & Metrics",
        desc: "Observability patterns. Grafana dashboards and alerting.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "🔒",
        title: "Rate Limiting",
        desc: "LLM API rate limiting and cost control. Budget enforcement.",
        layer: :ai,
        livebook_url: "#",
        github_url: "#"
      },
      %{
        emoji: "🌐",
        title: "Distributed Agents",
        desc: "Multi-node agent deployment. Failover and redistribution.",
        layer: :core,
        livebook_url: "#",
        github_url: "#"
      }
    ]
  end
end
