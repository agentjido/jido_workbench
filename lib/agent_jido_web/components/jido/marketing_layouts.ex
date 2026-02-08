defmodule AgentJidoWeb.Jido.MarketingLayouts do
  @moduledoc """
  Layout components for Jido marketing pages.
  """
  use AgentJidoWeb, :html

  alias Phoenix.LiveView.JS
  alias AgentJidoWeb.Jido.Nav

  attr :title, :string, default: "Jido"
  attr :current_path, :string, default: "/"
  slot :inner_block, required: true

  def marketing_layout(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col bg-background text-foreground">
      <.marketing_header current_path={@current_path} />
      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>
      <.marketing_footer />
    </div>
    """
  end

  attr :current_path, :string, default: "/"

  def marketing_header(assigns) do
    assigns = assign(assigns, :nav_links, Nav.marketing_nav_links())

    ~H"""
    <%!-- Theme Toggle - Fixed position --%>
    <div class="fixed top-4 right-4 z-[100] flex gap-1 bg-surface border border-border rounded p-1">
      <button
        id="theme-dark-btn"
        phx-hook="ThemeToggle"
        data-theme="dark"
        class="px-3 py-1.5 rounded text-[10px] font-semibold transition-colors bg-primary text-primary-foreground"
      >
        DARK
      </button>
      <button
        id="theme-light-btn"
        phx-hook="ThemeToggle"
        data-theme="light"
        class="px-3 py-1.5 rounded text-[10px] font-semibold transition-colors text-muted-foreground hover:text-foreground"
      >
        LIGHT
      </button>
    </div>

    <header class="sticky top-0 z-50 bg-background/80 backdrop-blur-md pt-6 pb-12" id="main-header" phx-hook="ScrollShrink">
      <div class="container max-w-[1000px] mx-auto px-6">
        <nav class="nav-surface flex justify-between items-center px-6 py-5 transition-all duration-300">
          <Nav.logo />

          <%!-- Desktop Navigation --%>
          <div class="hidden md:flex items-center gap-7">
            <%= for {label, href} <- @nav_links do %>
              <.link
                navigate={href}
                class={"text-xs transition-colors #{if @current_path == href, do: "text-primary font-semibold", else: "text-secondary-foreground hover:text-foreground"}"}
              >
                {label}
              </.link>
            <% end %>
            <a
              href="mailto:support@agentjido.com?subject=Premium%20Support%20Inquiry"
              class="text-xs font-medium bg-gradient-to-r from-accent-yellow to-accent-red bg-clip-text text-transparent hover:opacity-80 transition-opacity"
            >
              Premium Support
            </a>
          </div>

          <%!-- CTA --%>
          <div class="hidden md:block">
            <.link
              navigate="/getting-started"
              class="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold px-4 py-2.5 rounded transition-colors"
            >
              $ GET STARTED
            </.link>
          </div>

          <%!-- Mobile Menu Button --%>
          <button class="md:hidden text-foreground" phx-click={JS.toggle(to: "#mobile-menu")}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </nav>

        <%!-- Mobile Menu --%>
        <div id="mobile-menu" class="hidden md:hidden mt-4 nav-surface p-4 space-y-3">
          <%= for {label, href} <- @nav_links do %>
            <.link
              navigate={href}
              class={"block px-4 py-3 text-xs rounded transition-colors #{if @current_path == href, do: "text-primary bg-primary/10 font-semibold", else: "text-secondary-foreground hover:text-foreground hover:bg-muted"}"}
            >
              {label}
            </.link>
          <% end %>
          <a
            href="mailto:support@agentjido.com?subject=Premium%20Support%20Inquiry"
            class="block px-4 py-3 text-xs rounded bg-gradient-to-r from-accent-yellow to-accent-red bg-clip-text text-transparent font-medium"
          >
            Premium Support
          </a>
          <.link
            navigate="/getting-started"
            class="block bg-primary text-primary-foreground text-xs font-bold px-4 py-2.5 rounded text-center mt-4"
          >
            $ GET STARTED
          </.link>
        </div>
      </div>
    </header>
    """
  end

  def marketing_footer(assigns) do
    assigns =
      assigns
      |> assign(:current_year, Date.utc_today().year)
      |> assign(:company_links, Nav.footer_company_links())
      |> assign(:resource_links, Nav.footer_resource_links())
      |> assign(:package_links, Nav.footer_package_links())
      |> assign(:social_links, Nav.social_links())

    ~H"""
    <footer class="border-t border-border bg-background">
      <div class="container max-w-[1000px] mx-auto px-6 py-12 md:py-16">
        <div class="grid grid-cols-2 md:grid-cols-6 gap-8 md:gap-12">
          <%!-- Brand Column --%>
          <div class="col-span-2">
            <Nav.logo class="mb-4" show_version={false} logo_size="w-8 h-8 text-sm" text_size="text-lg" />
            <p class="text-muted-foreground text-sm mb-6">
              BEAM-native agent framework for Elixir
            </p>

            <%!-- Status Indicator --%>
            <div class="flex items-center gap-2 mb-6">
              <span class="w-2 h-2 rounded-full bg-primary animate-pulse" />
              <span class="text-muted-foreground text-xs">All systems operational</span>
            </div>

            <div class="text-muted-foreground text-xs space-y-1">
              <p>Made with ❤️ for the BEAM</p>
              <p>Copyright © 2024–{@current_year} AgentJido</p>
            </div>
          </div>

          <%!-- Company --%>
          <div>
            <h4 class="text-xs font-bold tracking-wider text-foreground mb-4">COMPANY</h4>
            <ul class="space-y-3">
              <%= for {label, href} <- @company_links do %>
                <li>
                  <.link navigate={href} class="text-sm text-muted-foreground hover:text-foreground transition-colors">
                    {label}
                  </.link>
                </li>
              <% end %>
            </ul>
          </div>

          <%!-- Resources --%>
          <div>
            <h4 class="text-xs font-bold tracking-wider text-foreground mb-4">RESOURCES</h4>
            <ul class="space-y-3">
              <%= for {label, href} <- @resource_links do %>
                <li>
                  <.link navigate={href} class="text-sm text-muted-foreground hover:text-foreground transition-colors">
                    {label}
                  </.link>
                </li>
              <% end %>
            </ul>
          </div>

          <%!-- Social --%>
          <div>
            <h4 class="text-xs font-bold tracking-wider text-foreground mb-4">SOCIAL</h4>
            <ul class="space-y-3">
              <%= for {icon, label, href} <- @social_links do %>
                <li>
                  <a
                    href={href}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    <Nav.social_icon icon={icon} /> {label}
                  </a>
                </li>
              <% end %>
            </ul>
          </div>

          <%!-- Packages --%>
          <div>
            <h4 class="text-xs font-bold tracking-wider text-foreground mb-4">PACKAGES</h4>
            <ul class="space-y-3">
              <%= for {label, href} <- @package_links do %>
                <li>
                  <a href={href} target="_blank" rel="noopener noreferrer" class="text-sm text-muted-foreground hover:text-foreground transition-colors">
                    {label}
                  </a>
                </li>
              <% end %>
            </ul>
          </div>
        </div>

        <%!-- Bottom Bar --%>
        <div class="mt-12 pt-8 border-t border-border flex flex-col md:flex-row justify-between items-center gap-4">
          <div class="flex items-center gap-4 text-xs text-muted-foreground">
            <span>MIT License</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-xs text-muted-foreground">Jido {Nav.jido_version()}</span>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
