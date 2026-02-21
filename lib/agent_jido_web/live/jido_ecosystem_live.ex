defmodule AgentJidoWeb.JidoEcosystemLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.Ecosystem
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
    package_cards = LandingContent.packages_from(public_packages)
    name_by_id = Map.new(public_packages, &{&1.id, &1.title})

    {:ok,
     assign(socket,
       page_title: "Jido Ecosystem",
       meta_description: "Discover composable Jido packages across runtime core, AI orchestration, and production operations.",
       selected_layer: :all,
       packages: package_cards,
       layer_rows: build_layer_rows(public_packages),
       package_name_by_id: name_by_id,
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
              navigate="/ecosystem/package-matrix"
              class="text-xs text-primary hover:text-primary/80 transition-colors font-semibold"
            >
              VIEW PACKAGE MATRIX →
            </.link>
          </div>
        </section>

        <%!-- Layered Map Section --%>
        <section class="mb-16">
          <div class="flex justify-between items-center mb-5">
            <span class="text-sm font-bold tracking-wider">LAYERED ECOSYSTEM MAP</span>
            <span class="text-[11px] text-muted-foreground">curated architecture view</span>
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
end
