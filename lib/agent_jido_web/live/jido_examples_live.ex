defmodule AgentJidoWeb.JidoExamplesLive do
  @moduledoc """
  Examples index page, driven by NimblePublisher content from priv/examples/.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Examples

  @impl true
  def mount(_params, _session, socket) do
    examples = Examples.all_examples()
    categories = Examples.all_categories()

    {:ok,
     assign(socket,
       page_title: "Jido Examples",
       meta_description: "Run practical examples that show how to design, coordinate, and operate agents with Jido.",
       examples: examples,
       categories: categories,
       core_examples: Examples.examples_by_category(:core),
       ai_examples: Examples.examples_by_category(:ai),
       production_examples: Examples.examples_by_category(:production)
     )}
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
            Interactive examples with real, running code. Each example includes source code, explanation, and a live demo you can play with.
          </p>
        </section>

        <%!-- Core Examples --%>
        <section :if={@core_examples != []} class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">GETTING STARTED</span>
            <span class="text-[10px] px-2 py-1 rounded bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan font-semibold">
              CORE
            </span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for example <- @core_examples do %>
              <.example_card example={example} />
            <% end %>
          </div>
        </section>

        <%!-- AI Examples --%>
        <section :if={@ai_examples != []} class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">AI-POWERED AGENTS</span>
            <span class="text-[10px] px-2 py-1 rounded bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow font-semibold">
              AI
            </span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for example <- @ai_examples do %>
              <.example_card example={example} />
            <% end %>
          </div>
        </section>

        <%!-- Production Examples --%>
        <section :if={@production_examples != []} class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider">PRODUCTION PATTERNS</span>
            <span class="text-[10px] px-2 py-1 rounded bg-primary/10 border border-primary/30 text-primary font-semibold">
              PRODUCTION
            </span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for example <- @production_examples do %>
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
    <.link navigate={~p"/examples/#{@example.slug}"} class="feature-card group block">
      <div class="flex justify-between items-start mb-3">
        <span class="text-lg">{@example.emoji}</span>
        <div class="flex gap-2">
          <span class={"text-[10px] px-2 py-0.5 rounded font-semibold uppercase #{difficulty_badge(@example.difficulty)}"}>
            {@example.difficulty}
          </span>
        </div>
      </div>
      <h3 class="font-bold text-[15px] mb-2 group-hover:text-primary transition-colors">
        {@example.title}
      </h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@example.description}</p>
      <div class="flex gap-2 flex-wrap">
        <%= for tag <- @example.tags do %>
          <span class="text-[10px] px-2 py-0.5 rounded bg-elevated text-muted-foreground">
            {tag}
          </span>
        <% end %>
      </div>
    </.link>
    """
  end

  defp difficulty_badge(:beginner), do: "bg-green-500/10 text-green-400"
  defp difficulty_badge(:intermediate), do: "bg-amber-500/10 text-amber-400"
  defp difficulty_badge(:advanced), do: "bg-red-500/10 text-red-400"
  defp difficulty_badge(_), do: "bg-elevated text-muted-foreground"
end
