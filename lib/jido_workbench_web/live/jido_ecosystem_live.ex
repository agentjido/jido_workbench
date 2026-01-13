defmodule JidoWorkbenchWeb.JidoEcosystemLive do
  use JidoWorkbenchWeb, :live_view

  import JidoWorkbenchWeb.Jido.MarketingLayouts
  import JidoWorkbenchWeb.Jido.MarketingCards

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
    <.marketing_layout>
      <div class="container max-w-[1000px] mx-auto px-6">
        <section class="py-16 text-center">
          <h1 class="text-3xl md:text-4xl font-bold mb-4">The Jido Ecosystem</h1>
          <p class="text-muted-foreground text-sm max-w-2xl mx-auto">
            A comprehensive suite of packages for building AI-powered applications on the BEAM.
          </p>
        </section>

        <!-- Filter Buttons -->
        <div class="flex flex-wrap gap-2 justify-center mb-8">
          <button
            phx-click="filter_layer"
            phx-value-layer="all"
            class={"px-4 py-2 text-xs rounded transition-colors #{if @selected_layer == :all, do: "bg-primary text-primary-foreground", else: "bg-secondary text-secondary-foreground hover:bg-secondary/80"}"}
          >
            All
          </button>
          <button
            phx-click="filter_layer"
            phx-value-layer="core"
            class={"px-4 py-2 text-xs rounded transition-colors #{if @selected_layer == :core, do: "bg-primary text-primary-foreground", else: "bg-secondary text-secondary-foreground hover:bg-secondary/80"}"}
          >
            Core
          </button>
          <button
            phx-click="filter_layer"
            phx-value-layer="ai"
            class={"px-4 py-2 text-xs rounded transition-colors #{if @selected_layer == :ai, do: "bg-primary text-primary-foreground", else: "bg-secondary text-secondary-foreground hover:bg-secondary/80"}"}
          >
            AI
          </button>
          <button
            phx-click="filter_layer"
            phx-value-layer="foundation"
            class={"px-4 py-2 text-xs rounded transition-colors #{if @selected_layer == :foundation, do: "bg-primary text-primary-foreground", else: "bg-secondary text-secondary-foreground hover:bg-secondary/80"}"}
          >
            Foundation
          </button>
          <button
            phx-click="filter_layer"
            phx-value-layer="app"
            class={"px-4 py-2 text-xs rounded transition-colors #{if @selected_layer == :app, do: "bg-primary text-primary-foreground", else: "bg-secondary text-secondary-foreground hover:bg-secondary/80"}"}
          >
            Application
          </button>
        </div>

        <!-- Package Grid -->
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4 pb-16">
          <%= for pkg <- filtered_packages(@selected_layer) do %>
            <.package_card
              name={pkg.name}
              desc={pkg.desc}
              layer={pkg.layer}
              links={pkg.links}
            />
          <% end %>
        </div>
      </div>
    </.marketing_layout>
    """
  end

  defp filtered_packages(:all), do: packages()
  defp filtered_packages(layer), do: Enum.filter(packages(), &(&1.layer == layer))

  defp packages do
    [
      %{name: "jido", desc: "Core agent runtime with workflows, actions, and state management.", layer: :core, links: %{"Hex" => "https://hex.pm/packages/jido"}},
      %{name: "jido_action", desc: "Action primitives and execution engine.", layer: :core, links: %{"Hex" => "https://hex.pm/packages/jido_action"}},
      %{name: "jido_signal", desc: "Event-driven signal processing for agents.", layer: :core, links: %{"Hex" => "https://hex.pm/packages/jido_signal"}},
      %{name: "jido_ai", desc: "LLM integrations, prompt engineering, and AI-powered actions.", layer: :ai, links: %{"Hex" => "https://hex.pm/packages/jido_ai"}},
      %{name: "jido_chat", desc: "Conversational AI with multi-turn memory and tool use.", layer: :app, links: %{"Hex" => "https://hex.pm/packages/jido_chat"}},
      %{name: "jido_memory", desc: "Flexible memory backends for agent state persistence.", layer: :foundation, links: %{"Hex" => "https://hex.pm/packages/jido_memory"}},
      %{name: "jido_discovery", desc: "Service discovery and agent registry.", layer: :foundation, links: %{"Hex" => "https://hex.pm/packages/jido_discovery"}},
    ]
  end
end
