defmodule AgentJidoWeb.JidoEcosystemLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.GraphAscii
  alias AgentJido.LandingContent

  import AgentJidoWeb.Jido.MarketingLayouts
  import AgentJidoWeb.Jido.MarketingCards

  @impl true
  def mount(_params, _session, socket) do
    ecosystem_packages = Ecosystem.public_packages()
    package_cards = LandingContent.packages_from(ecosystem_packages)
    graph_model = GraphAscii.build_model(ecosystem_packages)
    graph_name_by_id = Map.new(graph_model.nodes, &{&1.id, &1.name})

    {:ok,
     assign(socket,
       selected_layer: :all,
       packages: package_cards,
       graph_layers: graph_model.layers,
       graph_name_by_id: graph_name_by_id,
       og_image: "https://agentjido.xyz/og/ecosystem.png",
       package_count: length(package_cards),
       layer_count: count_layers(package_cards),
       edge_count: length(graph_model.edges)
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
          <div class="flex gap-6 mb-8">
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@package_count}</span>
              <span class="text-muted-foreground text-xs">packages</span>
            </div>
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@layer_count}</span>
              <span class="text-muted-foreground text-xs">layers</span>
            </div>
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@edge_count}</span>
              <span class="text-muted-foreground text-xs">dependency edges</span>
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
              <span class="text-[10px] text-muted-foreground">dependency_graph.html</span>
            </div>
            <div class="p-6">
              <div class="ecosystem-layered-graph" id="ecosystem-layered-graph">
                <div :if={@graph_layers == []} class="text-xs text-muted-foreground">
                  No public package relationships found.
                </div>
                <%= for {layer, layer_index} <- Enum.with_index(@graph_layers) do %>
                  <section class="ecosystem-graph-layer">
                    <div class="ecosystem-layer-header">
                      <span class={"ecosystem-layer-title #{node_text_class(layer.id)}"}>
                        {layer.label}
                      </span>
                      <span class="ecosystem-layer-summary">
                        {layer.summary}
                      </span>
                    </div>
                    <%= for row <- layer.rows do %>
                      <div
                        class="ecosystem-depth-grid ecosystem-layer-row"
                        style={"--ecosystem-cols: #{max(length(row), 1)}"}
                      >
                        <%= for node <- row do %>
                          <article class={"ecosystem-graph-node ecosystem-node-#{node.layer}"}>
                            <.link
                              navigate={"/ecosystem/#{node.id}"}
                              class={"ecosystem-node-name #{node_text_class(node.layer)}"}
                            >
                              {node.name}
                            </.link>
                            <p class="ecosystem-node-desc">{node.short_desc}</p>
                            <div class="ecosystem-node-dependencies">
                              <span class="ecosystem-node-meta-label">depends on</span>
                              <%= if node.deps == [] do %>
                                <span class="ecosystem-node-chip ecosystem-node-chip-muted">none</span>
                              <% else %>
                                <%= for dep_id <- node.deps do %>
                                  <.link navigate={"/ecosystem/#{dep_id}"} class="ecosystem-node-chip">
                                    {Map.get(@graph_name_by_id, dep_id, dep_id)}
                                  </.link>
                                <% end %>
                              <% end %>
                            </div>
                          </article>
                        <% end %>
                      </div>
                    <% end %>
                  </section>
                  <div :if={layer_index < length(@graph_layers) - 1} class="ecosystem-layer-divider"></div>
                <% end %>
              </div>
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

  defp node_text_class(:foundation), do: "text-accent-cyan"
  defp node_text_class(:core), do: "text-accent-green"
  defp node_text_class(:ai), do: "text-accent-yellow"
  defp node_text_class(:app), do: "text-accent-red"
  defp node_text_class(_), do: "text-primary"
end
