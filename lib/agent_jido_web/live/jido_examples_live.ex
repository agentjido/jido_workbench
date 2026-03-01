defmodule AgentJidoWeb.JidoExamplesLive do
  @moduledoc """
  Examples index page, driven by NimblePublisher content from priv/examples/.
  """

  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Examples

  @category_order [:core, :ai, :production]

  @impl true
  def mount(_params, session, socket) do
    include_drafts = Map.get(session, "examples_include_drafts", false)

    {:ok,
     socket
     |> assign(:page_title, "Jido Examples")
     |> assign(
       :meta_description,
       "Run practical examples that show how to design, coordinate, and operate agents with Jido."
     )
     |> assign(:include_drafts, include_drafts)
     |> assign(:examples, [])
     |> assign(:grouped_examples, %{})
     |> assign(:categories_to_render, [])
     |> assign(:match_count, 0)
     |> load_examples()}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, load_examples(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/examples"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <%!-- Hero --%>
        <section class="text-center mb-12">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              EXAMPLES & TUTORIALS
            </span>
          </div>
          <h1 class="text-4xl font-bold mb-4">
            Learn by <span class="text-primary">building</span>
          </h1>
          <p class="copy-measure-wide mx-auto text-lg text-muted-foreground">
            Interactive examples with source code, explanation, and live demos.
            AI/browser demos can run in deterministic simulated mode so no external model calls are required.
          </p>
          <div :if={@include_drafts} class="mt-4">
            <span class="text-[10px] px-2 py-0.5 rounded font-semibold uppercase bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow">
              admin preview
            </span>
          </div>
        </section>

        <%!-- Empty state --%>
        <section :if={@examples == []} class="mb-16 rounded-lg border border-border bg-card p-10 text-center">
          <h2 class="text-xl font-bold mb-2">No examples available yet</h2>
          <p class="text-sm text-muted-foreground">
            Check back soon for more runnable examples.
          </p>
        </section>

        <%= for category <- @categories_to_render do %>
          <section class="mb-16">
            <div class="flex justify-between items-center mb-6">
              <span class="text-sm font-bold tracking-wider">{category_heading(category)}</span>
              <span class={"text-[10px] px-2 py-1 rounded font-semibold #{category_badge_class(category)}"}>
                {String.upcase(Atom.to_string(category))}
              </span>
            </div>
            <div class="grid md:grid-cols-2 gap-4">
              <%= for example <- Map.get(@grouped_examples, category, []) do %>
                <.example_card example={example} />
              <% end %>
            </div>
          </section>
        <% end %>

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
              rel="noopener noreferrer"
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
      <div class="flex justify-end items-start mb-3">
        <div class="flex gap-2">
          <span class={"text-[10px] px-2 py-0.5 rounded font-semibold uppercase #{difficulty_badge(@example.difficulty)}"}>
            {@example.difficulty}
          </span>
          <span
            :if={@example.demo_mode == :simulated}
            class="text-[10px] px-2 py-0.5 rounded font-semibold uppercase bg-accent-cyan/10 text-accent-cyan border border-accent-cyan/30"
          >
            simulated
          </span>
        </div>
      </div>
      <h3 class="font-bold text-[15px] mb-2 group-hover:text-primary transition-colors">
        {@example.title}
      </h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@example.description}</p>
      <div class="flex gap-2 flex-wrap mb-2">
        <span class="text-[10px] px-2 py-0.5 rounded bg-primary/10 border border-primary/20 text-primary">
          {labelize(@example.scenario_cluster)}
        </span>
        <span class="text-[10px] px-2 py-0.5 rounded bg-elevated text-muted-foreground">
          {labelize(@example.capability_theme)}
        </span>
      </div>
      <div class="flex gap-2 flex-wrap">
        <%= for tag <- Enum.take(List.wrap(@example.tags), 3) do %>
          <span class="text-[10px] px-2 py-0.5 rounded bg-elevated text-muted-foreground">
            {tag}
          </span>
        <% end %>
      </div>
    </.link>
    """
  end

  defp load_examples(socket) do
    opts = if socket.assigns.include_drafts, do: [include_drafts: true], else: []
    examples = Examples.all_examples(opts)
    grouped_examples = Enum.group_by(examples, & &1.category)

    categories_to_render =
      @category_order
      |> Enum.filter(&(Map.get(grouped_examples, &1, []) != []))

    socket
    |> assign(:examples, examples)
    |> assign(:grouped_examples, grouped_examples)
    |> assign(:categories_to_render, categories_to_render)
    |> assign(:match_count, length(examples))
  end

  defp labelize(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp labelize(value), do: to_string(value)

  defp category_heading(:core), do: "Getting Started"
  defp category_heading(:ai), do: "AI-Powered Agents"
  defp category_heading(:production), do: "Production Patterns"
  defp category_heading(_), do: "Examples"

  defp category_badge_class(:core), do: "bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan"
  defp category_badge_class(:ai), do: "bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow"
  defp category_badge_class(:production), do: "bg-primary/10 border border-primary/30 text-primary"
  defp category_badge_class(_), do: "bg-elevated border border-border text-muted-foreground"

  defp difficulty_badge(:beginner), do: "bg-accent-green/10 text-accent-green"
  defp difficulty_badge(:intermediate), do: "bg-accent-yellow/10 text-accent-yellow"
  defp difficulty_badge(:advanced), do: "bg-accent-red/10 text-accent-red"
  defp difficulty_badge(_), do: "bg-elevated text-muted-foreground"
end
