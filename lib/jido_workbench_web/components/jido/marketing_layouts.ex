defmodule JidoWorkbenchWeb.Jido.MarketingLayouts do
  @moduledoc """
  Layout components for Jido marketing pages.
  """
  use JidoWorkbenchWeb, :html

  attr :title, :string, default: "Jido"
  slot :inner_block, required: true

  def marketing_layout(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col bg-background text-foreground">
      <.marketing_header />
      <main class="flex-1">
        <%= render_slot(@inner_block) %>
      </main>
      <.marketing_footer />
    </div>
    """
  end

  def marketing_header(assigns) do
    ~H"""
    <header class="sticky top-0 z-50 bg-background/80 backdrop-blur-md pt-6 pb-12">
      <div class="container max-w-[1000px] mx-auto px-6">
        <nav class="nav-surface flex justify-between items-center px-6 py-5">
          <!-- Logo -->
          <.link navigate="/" class="flex items-center gap-2.5">
            <div class="w-7 h-7 rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow text-sm">
              J
            </div>
            <span class="font-bold tracking-wide">JIDO</span>
            <span class="text-muted-foreground text-[11px] ml-1">v0.1.0</span>
          </.link>

          <!-- Desktop Navigation -->
          <div class="hidden md:flex items-center gap-7">
            <.link navigate="/ecosystem" class="text-xs text-secondary-foreground hover:text-foreground transition-colors">/ecosystem</.link>
            <.link navigate="/partners" class="text-xs text-secondary-foreground hover:text-foreground transition-colors">/partners</.link>
            <.link navigate="/examples" class="text-xs text-secondary-foreground hover:text-foreground transition-colors">/examples</.link>
            <.link navigate="/benchmarks" class="text-xs text-secondary-foreground hover:text-foreground transition-colors">/benchmarks</.link>
            <.link navigate="/docs" class="text-xs text-secondary-foreground hover:text-foreground transition-colors">/docs</.link>
          </div>

          <!-- CTA -->
          <div class="hidden md:block">
            <.link navigate="/getting-started" class="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold px-4 py-2.5 rounded transition-colors">
              $ GET STARTED
            </.link>
          </div>

          <!-- Mobile Menu Button -->
          <button class="md:hidden text-foreground" phx-click={JS.toggle(to: "#mobile-menu")}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </nav>

        <!-- Mobile Menu -->
        <div id="mobile-menu" class="hidden md:hidden mt-4 nav-surface p-4 space-y-3">
          <.link navigate="/ecosystem" class="block text-sm text-secondary-foreground hover:text-foreground">/ecosystem</.link>
          <.link navigate="/partners" class="block text-sm text-secondary-foreground hover:text-foreground">/partners</.link>
          <.link navigate="/examples" class="block text-sm text-secondary-foreground hover:text-foreground">/examples</.link>
          <.link navigate="/benchmarks" class="block text-sm text-secondary-foreground hover:text-foreground">/benchmarks</.link>
          <.link navigate="/docs" class="block text-sm text-secondary-foreground hover:text-foreground">/docs</.link>
          <.link navigate="/getting-started" class="block bg-primary text-primary-foreground text-sm font-bold px-4 py-2.5 rounded text-center mt-4">
            $ GET STARTED
          </.link>
        </div>
      </div>
    </header>
    """
  end

  def marketing_footer(assigns) do
    ~H"""
    <footer class="border-t border-border py-8 mt-16">
      <div class="container max-w-[1000px] mx-auto px-6">
        <div class="flex flex-col md:flex-row justify-between items-center gap-4">
          <div class="flex items-center gap-2">
            <div class="w-5 h-5 rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow text-[10px]">
              J
            </div>
            <span class="text-sm font-bold">JIDO</span>
          </div>
          <div class="flex gap-6 text-xs text-muted-foreground">
            <a href="https://github.com/agentjido" target="_blank" class="hover:text-foreground transition-colors">GitHub</a>
            <a href="https://discord.gg/jido" target="_blank" class="hover:text-foreground transition-colors">Discord</a>
            <a href="https://hex.pm/packages/jido" target="_blank" class="hover:text-foreground transition-colors">Hex.pm</a>
          </div>
          <p class="text-xs text-muted-foreground">© 2024 AgentJido. MIT License.</p>
        </div>
      </div>
    </footer>
    """
  end
end
