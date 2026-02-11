defmodule AgentJidoWeb.CatalogLive do
  use AgentJidoWeb, :live_view
  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Jido Discovery Catalog",
       og_image: "https://agentjido.xyz/og/catalog.png"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/catalog">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <div class="text-center mb-12">
          <h1 class="text-4xl font-bold text-foreground mb-4">
            Jido <span class="gradient-text">Catalog</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-3xl mx-auto">
            Explore and discover all available components in the Jido ecosystem. The catalog provides a comprehensive reference of Actions, Agents, Sensors, and Skills that you can use to build powerful workflows.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <.catalog_card
            title="Actions"
            icon="hero-bolt"
            description="Browse available actions that can be executed within workflows. Actions are the building blocks for creating complex automations."
            link="/catalog/actions"
          />

          <.catalog_card
            title="Agents"
            icon="hero-user-circle"
            description="Discover AI agents that can perform specific tasks or roles. Agents combine multiple skills to achieve complex goals."
            link="/catalog/agents"
          />

          <.catalog_card
            title="Sensors"
            icon="hero-signal"
            description="Explore available sensors that can monitor and collect data from various sources in real-time."
            link="/catalog/sensors"
          />

          <.catalog_card
            title="Skills"
            icon="hero-academic-cap"
            description="View the collection of skills that agents can use. Skills are specialized capabilities that enable specific functionalities."
            link="/catalog/skills"
          />
        </div>
      </div>
    </.marketing_layout>
    """
  end

  defp catalog_card(assigns) do
    ~H"""
    <.link
      navigate={@link}
      class="block p-6 bg-card rounded-lg border border-border hover:border-primary/30 transition-colors"
    >
      <div class="flex items-center gap-3 mb-4">
        <div class="text-primary">
          <.icon name={@icon} class="w-8 h-8" />
        </div>
        <h2 class="text-2xl font-semibold text-foreground">{@title}</h2>
      </div>
      <p class="text-muted-foreground">{@description}</p>
      <div class="mt-4 flex items-center text-primary font-medium">
        Explore {@title}
        <.icon name="hero-arrow-right" class="w-4 h-4 ml-2" />
      </div>
    </.link>
    """
  end
end
