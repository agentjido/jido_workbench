defmodule AgentJidoWeb.JidoExamplesLive do
  @moduledoc """
  Examples index page, driven by NimblePublisher content from priv/examples/.

  Supports URL-based taxonomy filtering for category, scenario cluster,
  capability theme, and rollout wave.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Examples

  @category_order [:core, :ai, :production]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Jido Examples")
     |> assign(
       :meta_description,
       "Run practical examples that show how to design, coordinate, and operate agents with Jido."
     )
     |> assign(:filter_options, filter_options())
     |> assign(:filters, default_filters())
     |> assign(:examples, [])
     |> assign(:grouped_examples, %{})
     |> assign(:categories_to_render, [])
     |> assign(:match_count, 0)
     |> apply_filters(default_filters())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = parse_filters(params)
    {:noreply, apply_filters(socket, filters)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/examples"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
      <div class="container max-w-[1080px] mx-auto px-6 py-12">
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
          <p class="text-lg text-muted-foreground max-w-2xl mx-auto">
            Interactive examples with source code, explanation, and live demos.
            AI/browser demos can run in deterministic simulated mode so no external model calls are required.
          </p>
        </section>

        <%!-- Taxonomy Filters --%>
        <section class="mb-12 rounded-lg border border-border bg-card p-6">
          <div class="flex flex-wrap items-center justify-between gap-3 mb-5">
            <h2 class="text-lg font-bold">Browse by Taxonomy</h2>
            <div class="text-xs text-muted-foreground">{@match_count} example(s)</div>
          </div>

          <div class="space-y-4">
            <.filter_row
              label="Category"
              filters={@filters}
              key_name={:category}
              values={@filter_options.categories}
            />
            <.filter_row
              label="Scenario"
              filters={@filters}
              key_name={:scenario_cluster}
              values={@filter_options.scenario_clusters}
            />
            <.filter_row
              label="Capability Theme"
              filters={@filters}
              key_name={:capability_theme}
              values={@filter_options.capability_themes}
            />
            <.filter_row label="Wave" filters={@filters} key_name={:wave} values={@filter_options.waves} />
          </div>

          <div :if={filters_active?(@filters)} class="mt-5">
            <.link
              patch={~p"/examples"}
              class="text-xs text-primary hover:opacity-80 transition-opacity font-semibold"
            >
              Clear filters
            </.link>
          </div>
        </section>

        <%!-- Empty state --%>
        <section :if={@examples == []} class="mb-16 rounded-lg border border-border bg-card p-10 text-center">
          <h2 class="text-xl font-bold mb-2">No examples match these filters</h2>
          <p class="text-sm text-muted-foreground mb-4">
            Try clearing one filter or selecting a broader taxonomy slice.
          </p>
          <.link
            patch={~p"/examples"}
            class="inline-block bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-5 py-2 rounded transition-colors"
          >
            Show all live examples
          </.link>
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

  attr :label, :string, required: true
  attr :filters, :map, required: true
  attr :key_name, :atom, required: true
  attr :values, :list, required: true

  defp filter_row(assigns) do
    ~H"""
    <div>
      <div class="text-[11px] text-muted-foreground uppercase tracking-wider mb-2">{@label}</div>
      <div class="flex gap-2 flex-wrap">
        <.filter_chip
          label="All"
          active={Map.get(@filters, @key_name) == nil}
          params={patch_params(@filters, @key_name, nil)}
        />
        <%= for value <- @values do %>
          <.filter_chip
            label={labelize(value)}
            active={Map.get(@filters, @key_name) == value}
            params={patch_params(@filters, @key_name, value)}
          />
        <% end %>
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :active, :boolean, required: true
  attr :params, :map, required: true

  defp filter_chip(assigns) do
    ~H"""
    <.link
      patch={~p"/examples?#{@params}"}
      class={
        if @active,
          do: "text-[11px] px-3 py-1 rounded border border-primary/40 bg-primary/10 text-primary font-semibold transition-colors",
          else: "text-[11px] px-3 py-1 rounded border border-border bg-elevated text-muted-foreground hover:text-foreground transition-colors"
      }
    >
      {@label}
    </.link>
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

  defp apply_filters(socket, filters) do
    examples = Examples.all_examples(filter_to_opts(filters))
    grouped_examples = Enum.group_by(examples, & &1.category)

    categories_to_render =
      @category_order
      |> Enum.filter(&(Map.get(grouped_examples, &1, []) != []))

    socket
    |> assign(:filters, filters)
    |> assign(:examples, examples)
    |> assign(:grouped_examples, grouped_examples)
    |> assign(:categories_to_render, categories_to_render)
    |> assign(:match_count, length(examples))
  end

  defp filter_options do
    %{
      categories: Examples.all_categories(),
      scenario_clusters: Examples.all_scenario_clusters(),
      capability_themes: Examples.all_capability_themes(),
      waves: Examples.all_waves()
    }
  end

  defp parse_filters(params) do
    %{
      category: parse_enum(params["category"], Examples.all_categories()),
      scenario_cluster: parse_enum(params["scenario"], Examples.all_scenario_clusters()),
      capability_theme: parse_enum(params["theme"], Examples.all_capability_themes()),
      wave: parse_enum(params["wave"], Examples.all_waves())
    }
  end

  defp parse_enum(nil, _allowed), do: nil
  defp parse_enum("", _allowed), do: nil

  defp parse_enum(value, allowed) when is_binary(value) do
    normalized = value |> String.trim() |> String.downcase()
    Enum.find(allowed, fn candidate -> Atom.to_string(candidate) == normalized end)
  end

  defp parse_enum(_value, _allowed), do: nil

  defp filter_to_opts(filters) do
    filters
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.into([])
  end

  defp patch_params(filters, key, value) do
    filters
    |> Map.put(key, value)
    |> query_map()
  end

  defp query_map(filters) do
    filters
    |> Enum.reduce(%{}, fn
      {_key, nil}, acc ->
        acc

      {:category, value}, acc ->
        Map.put(acc, "category", Atom.to_string(value))

      {:scenario_cluster, value}, acc ->
        Map.put(acc, "scenario", Atom.to_string(value))

      {:capability_theme, value}, acc ->
        Map.put(acc, "theme", Atom.to_string(value))

      {:wave, value}, acc ->
        Map.put(acc, "wave", Atom.to_string(value))
    end)
  end

  defp default_filters do
    %{
      category: nil,
      scenario_cluster: nil,
      capability_theme: nil,
      wave: nil
    }
  end

  defp filters_active?(filters) do
    Enum.any?(filters, fn {_key, value} -> not is_nil(value) end)
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

  defp difficulty_badge(:beginner), do: "bg-green-500/10 text-green-400"
  defp difficulty_badge(:intermediate), do: "bg-amber-500/10 text-amber-400"
  defp difficulty_badge(:advanced), do: "bg-red-500/10 text-red-400"
  defp difficulty_badge(_), do: "bg-elevated text-muted-foreground"
end
