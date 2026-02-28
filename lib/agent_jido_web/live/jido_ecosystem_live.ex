defmodule AgentJidoWeb.JidoEcosystemLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.Ecosystem
  alias AgentJido.GithubStarsTracker
  alias AgentJido.Ecosystem.Layering
  alias AgentJido.LandingContent

  import AgentJidoWeb.Jido.MarketingLayouts
  import AgentJidoWeb.Jido.MarketingCards

  @curated_layer_rows %{
    foundation: [~w(llm_db req_llm), ~w(jido_action jido_signal)],
    core: [~w(jido)],
    ai: [~w(jido_ai jido_browser), ~w(jido_memory jido_behaviortree jido_runic)],
    app: [~w(ash_jido jido_studio), ~w(jido_messaging jido_otel)]
  }

  @layer_order [:foundation, :core, :ai, :app]

  @impl true
  def mount(_params, _session, socket) do
    public_packages = Ecosystem.public_packages()
    stars_by_package = GithubStarsTracker.stars_map()
    package_cards = public_packages |> LandingContent.packages_from() |> attach_star_labels(stars_by_package)
    name_by_id = Map.new(public_packages, &{&1.id, &1.title})
    orbit_payload = build_orbit_payload(public_packages)

    {:ok,
     assign(socket,
       page_title: "Jido Ecosystem",
       meta_description: "Discover composable Jido packages across runtime core, AI orchestration, and production operations.",
       selected_layer: :all,
       packages: package_cards,
       layer_rows: build_layer_rows(public_packages),
       package_name_by_id: name_by_id,
       orbit_payload_json: Jason.encode!(orbit_payload),
       package_count: length(package_cards),
       layer_count: count_layers(package_cards)
     )}
  end

  @impl true
  def handle_event("filter_layer", %{"layer" => layer}, socket) do
    {:noreply, assign(socket, selected_layer: String.to_existing_atom(layer))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/ecosystem"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
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

          <p class="copy-measure text-sm leading-relaxed text-secondary-foreground mb-6">
            Use the full stack or pick the packages you need. Foundation packages for LLM handling,
            core framework for autonomy, and specialized packages for AI and coding workflows.
          </p>

          <%!-- Quick Stats --%>
          <div class="flex flex-wrap items-center gap-6 mb-8">
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@package_count}</span>
              <span class="text-muted-foreground text-xs">packages</span>
            </div>
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@layer_count}</span>
              <span class="text-muted-foreground text-xs">layers</span>
            </div>
            <.link
              navigate="/ecosystem/matrix"
              class="text-xs text-primary hover:text-primary/80 transition-colors font-semibold"
            >
              VIEW PACKAGE MATRIX →
            </.link>
          </div>
        </section>

        <%!-- Desktop Orbit Section --%>
        <section class="mb-16 hidden lg:block">
          <div class="flex justify-between items-center mb-5">
            <span class="text-sm font-bold tracking-wider">ECOSYSTEM MAP</span>
            <span class="text-[11px] text-muted-foreground">interactive architecture view</span>
          </div>

          <div
            id="ecosystem-orbit"
            phx-hook="EcosystemOrbit"
            data-orbit-payload={@orbit_payload_json}
            class="ecosystem-orbit-root"
          >
          </div>
        </section>

        <%!-- Mobile Layered Map Fallback --%>
        <section class="mb-16 lg:hidden">
          <div class="flex justify-between items-center mb-5">
            <span class="text-sm font-bold tracking-wider">LAYERED ECOSYSTEM MAP</span>
            <span class="text-[11px] text-muted-foreground">mobile architecture fallback</span>
          </div>

          <div class="space-y-4">
            <%= for layer <- @layer_rows do %>
              <article class="rounded-md border border-border bg-card/60 overflow-hidden">
                <div class="px-4 py-3 border-b border-border flex flex-col gap-1 sm:flex-row sm:items-center sm:justify-between">
                  <span class={"text-[11px] font-bold tracking-wider uppercase #{layer_title_class(layer.id)}"}>
                    {layer.label}
                  </span>
                  <span class="text-[11px] text-muted-foreground">{layer.summary}</span>
                </div>

                <div class="p-4 space-y-3">
                  <%= for row <- layer.rows do %>
                    <div class={row_grid_class(length(row))}>
                      <%= for pkg <- row do %>
                        <.link
                          navigate={pkg.path}
                          class="block rounded-md border border-border bg-card p-3 cursor-pointer transition-all duration-150 hover:border-primary/50 hover:-translate-y-0.5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
                        >
                          <div class="text-xs font-bold text-foreground">{pkg.name}</div>
                          <p class="text-[11px] text-muted-foreground leading-relaxed mt-1">{pkg.desc}</p>

                          <div class="mt-2 flex flex-wrap gap-1.5 items-center">
                            <span class="text-[9px] uppercase tracking-wider text-muted-foreground">depends on</span>
                            <%= if pkg.dep_ids == [] do %>
                              <span class="text-[10px] px-2 py-0.5 rounded border border-border/60 text-muted-foreground">none</span>
                            <% else %>
                              <%= for dep_id <- pkg.dep_ids do %>
                                <span class="text-[10px] px-2 py-0.5 rounded border border-border bg-surface text-foreground">
                                  {Map.get(@package_name_by_id, dep_id, dep_id)}
                                </span>
                              <% end %>
                            <% end %>
                          </div>
                        </.link>
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </article>
            <% end %>
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
            <%= for pkg <- displayed_packages(@packages, @selected_layer) do %>
              <.package_card
                name={pkg.name}
                desc={pkg.desc}
                layer={pkg.layer}
                path={pkg.path}
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

  defp displayed_packages(packages, :all), do: packages
  defp displayed_packages(packages, layer), do: Enum.filter(packages, &(&1.layer == layer))

  defp count_layers(packages) do
    packages
    |> Enum.map(& &1.layer)
    |> Enum.uniq()
    |> length()
  end

  defp build_layer_rows(public_packages) do
    package_map = Map.new(public_packages, &{&1.id, &1})

    @layer_order
    |> Enum.map(fn layer_id ->
      rows =
        @curated_layer_rows
        |> Map.get(layer_id, [])
        |> Enum.map(fn ids ->
          ids
          |> Enum.map(&to_layer_package(&1, package_map))
          |> Enum.reject(&is_nil/1)
        end)
        |> Enum.reject(&(&1 == []))

      %{
        id: layer_id,
        label: layer_label(layer_id),
        summary: layer_summary(layer_id),
        rows: rows
      }
    end)
    |> Enum.reject(&(&1.rows == []))
  end

  defp build_orbit_payload(public_packages) when is_list(public_packages) do
    public_ids = MapSet.new(public_packages, & &1.id)

    packages =
      public_packages
      |> Enum.map(&to_orbit_package(&1, public_ids))
      |> Enum.filter(& &1.visible)
      |> Enum.sort_by(fn pkg ->
        {orbit_layer_rank(pkg.layer), normalize_orbit_order(pkg.order), String.downcase(pkg.name)}
      end)

    center_id =
      packages
      |> Enum.find_value(fn pkg -> if pkg.layer == "core", do: pkg.id, else: nil end)

    domains =
      packages
      |> Enum.map(& &1.domain)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(fn domain ->
        %{
          id: domain,
          label: domain_label(domain)
        }
      end)

    %{
      center_id: center_id,
      layers: Enum.map(@layer_order, &Atom.to_string/1),
      domains: domains,
      packages: packages
    }
  end

  defp to_orbit_package(pkg, public_ids) do
    layer = Layering.layer_for(pkg)
    deps = pkg.ecosystem_deps |> List.wrap() |> Enum.filter(&MapSet.member?(public_ids, &1))

    %{
      id: pkg.id,
      name: pkg.name,
      title: pkg.title,
      path: "/ecosystem/#{pkg.id}",
      layer: Atom.to_string(layer),
      category: to_string_or_empty(pkg.category),
      domain: orbit_domain(pkg, layer),
      label: orbit_label(pkg),
      maturity: to_string_or_empty(pkg.maturity),
      deps: deps,
      order: Map.get(pkg, :orbit_order),
      weight: Map.get(pkg, :orbit_weight),
      visible: Map.get(pkg, :orbit_visible, true)
    }
  end

  defp orbit_domain(pkg, layer) do
    case Map.get(pkg, :orbit_domain) do
      nil ->
        case Map.get(pkg, :category) do
          nil -> Atom.to_string(layer)
          value -> to_string_or_empty(value)
        end

      value ->
        to_string_or_empty(value)
    end
  end

  defp orbit_label(pkg) do
    case Map.get(pkg, :orbit_label) do
      value when is_binary(value) and value != "" -> value
      _other -> pkg.graph_label || pkg.name
    end
  end

  defp domain_label(domain) when is_binary(domain) do
    domain
    |> String.replace("_", " ")
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp domain_label(other), do: other |> to_string() |> domain_label()

  defp normalize_orbit_order(order) when is_integer(order), do: order
  defp normalize_orbit_order(_order), do: 9_999

  defp orbit_layer_rank("foundation"), do: 1
  defp orbit_layer_rank("core"), do: 2
  defp orbit_layer_rank("ai"), do: 3
  defp orbit_layer_rank("app"), do: 4
  defp orbit_layer_rank(_layer), do: 99

  defp to_string_or_empty(value) when is_atom(value), do: Atom.to_string(value)
  defp to_string_or_empty(value) when is_binary(value), do: value
  defp to_string_or_empty(value) when is_integer(value), do: Integer.to_string(value)
  defp to_string_or_empty(value) when is_float(value), do: :erlang.float_to_binary(value, decimals: 2)
  defp to_string_or_empty(_value), do: ""

  defp to_layer_package(id, package_map) do
    case Map.get(package_map, id) do
      nil ->
        nil

      pkg ->
        %{
          id: pkg.id,
          name: pkg.name,
          path: "/ecosystem/#{pkg.id}",
          desc: pkg.tagline,
          layer: Layering.layer_for(pkg),
          dep_ids: pkg.ecosystem_deps || []
        }
    end
  end

  defp row_grid_class(size) when size <= 1, do: "grid grid-cols-1 gap-3"
  defp row_grid_class(2), do: "grid grid-cols-1 md:grid-cols-2 gap-3"
  defp row_grid_class(_), do: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3"

  defp layer_label(:foundation), do: "FOUNDATION LAYER"
  defp layer_label(:core), do: "CORE LAYER"
  defp layer_label(:ai), do: "AI LAYER"
  defp layer_label(:app), do: "APPLICATION LAYER"
  defp layer_label(_), do: "LAYER"

  defp layer_summary(:foundation), do: "Shared primitives for actions, signals, and model access"
  defp layer_summary(:core), do: "Agent lifecycle runtime and orchestration"
  defp layer_summary(:ai), do: "Reasoning, memory, and strategy packages"
  defp layer_summary(:app), do: "Integrations, delivery channels, and operator tooling"
  defp layer_summary(_), do: ""

  defp layer_title_class(:foundation), do: "text-accent-cyan"
  defp layer_title_class(:core), do: "text-accent-green"
  defp layer_title_class(:ai), do: "text-accent-yellow"
  defp layer_title_class(:app), do: "text-accent-red"
  defp layer_title_class(_), do: "text-primary"

  defp attach_star_labels(package_cards, stars_by_package) when is_list(package_cards) and is_map(stars_by_package) do
    Enum.map(package_cards, fn card ->
      with true <- is_map(card.links),
           github_url when is_binary(github_url) <- Map.get(card.links, "github"),
           %{stars: stars} when is_integer(stars) and stars >= 0 <- Map.get(stars_by_package, card.id) do
        stars_label = GithubStarsTracker.format_stars(stars)

        updated_links =
          card.links
          |> Map.delete("github")
          |> Map.put("github ★#{stars_label}", github_url)

        %{card | links: updated_links}
      else
        _other ->
          card
      end
    end)
  end
end
