defmodule AgentJidoWeb.Jido.MarketingLayouts do
  @moduledoc """
  Layout components for Jido marketing pages.
  """
  use AgentJidoWeb, :html

  alias Phoenix.LiveView.JS

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
    nav_links = [
      {"/ecosystem", "/ecosystem"},
      {"/partners", "/partners"},
      {"/examples", "/examples"},
      {"/benchmarks", "/benchmarks"},
      {"/docs", "/docs"}
    ]

    assigns = assign(assigns, :nav_links, nav_links)

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
          <%!-- Logo --%>
          <.link navigate="/" class="flex items-center gap-2.5">
            <div class="w-7 h-7 rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow text-sm transition-all duration-300">
              J
            </div>
            <span class="font-bold tracking-wide transition-all duration-300">JIDO</span>
            <span class="text-muted-foreground text-[11px] ml-1">v0.1.0</span>
          </.link>

          <%!-- Desktop Navigation --%>
          <div class="hidden md:flex items-center gap-7">
            <%= for {href, label} <- @nav_links do %>
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
          <%= for {href, label} <- @nav_links do %>
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
    current_year = Date.utc_today().year

    company_links = [
      {"About", "/about"},
      {"Blog", "/blog"},
      {"Careers", "/careers"},
      {"Contact", "/contact"},
      {"Partners", "/partners"}
    ]

    resource_links = [
      {"Docs", "/docs"},
      {"Changelog", "/changelog"},
      {"Examples", "/examples"},
      {"Community", "/community"},
      {"Benchmarks", "/benchmarks"}
    ]

    package_links = [
      {"Hex", "https://hex.pm/packages/jido"},
      {"HexDocs", "https://hexdocs.pm/jido"},
      {"jido", "https://hex.pm/packages/jido"},
      {"jido_ai", "https://hex.pm/packages/jido_ai"},
      {"req_llm", "https://hex.pm/packages/req_llm"}
    ]

    assigns =
      assigns
      |> assign(:current_year, current_year)
      |> assign(:company_links, company_links)
      |> assign(:resource_links, resource_links)
      |> assign(:package_links, package_links)

    ~H"""
    <footer class="border-t border-border bg-background">
      <div class="container max-w-[1000px] mx-auto px-6 py-12 md:py-16">
        <div class="grid grid-cols-2 md:grid-cols-6 gap-8 md:gap-12">
          <%!-- Brand Column --%>
          <div class="col-span-2">
            <.link navigate="/" class="flex items-center gap-2 mb-4">
              <div class="w-8 h-8 rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow text-sm">
                J
              </div>
              <span class="text-foreground font-bold text-lg tracking-tight">JIDO</span>
            </.link>
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
              <li>
                <a
                  href="https://discord.gg/jido"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  <.discord_icon /> Discord
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/agentjido/jido"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  <.github_icon /> GitHub
                </a>
              </li>
              <li>
                <a
                  href="https://x.com/agentjido"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  <.x_icon /> x.com
                </a>
              </li>
              <li>
                <a
                  href="https://linkedin.com/company/jido"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  <.linkedin_icon /> LinkedIn
                </a>
              </li>
              <li>
                <a
                  href="https://youtube.com/@agentjido"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  <.youtube_icon /> YouTube
                </a>
              </li>
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
            <span class="hidden md:inline">•</span>
            <.link navigate="/privacy" class="hover:text-foreground transition-colors">Privacy Policy</.link>
            <span class="hidden md:inline">•</span>
            <.link navigate="/terms" class="hover:text-foreground transition-colors">Terms of Service</.link>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-xs text-muted-foreground">Jido v0.1.0</span>
          </div>
        </div>
      </div>
    </footer>
    """
  end

  defp discord_icon(assigns) do
    ~H"""
    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
      <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z" />
    </svg>
    """
  end

  defp github_icon(assigns) do
    ~H"""
    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
    """
  end

  defp x_icon(assigns) do
    ~H"""
    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
    """
  end

  defp linkedin_icon(assigns) do
    ~H"""
    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
      <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
    </svg>
    """
  end

  defp youtube_icon(assigns) do
    ~H"""
    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
      <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
    </svg>
    """
  end
end
