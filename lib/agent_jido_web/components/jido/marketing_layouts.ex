defmodule AgentJidoWeb.Jido.MarketingLayouts do
  @moduledoc """
  Layout components for Jido marketing pages.
  """
  use AgentJidoWeb, :html

  alias AgentJidoWeb.Jido.Nav

  attr :title, :string, default: "Jido"
  attr :current_path, :string, default: "/"
  attr :show_nav_modals, :boolean, default: true
  slot :inner_block, required: true

  def marketing_layout(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col bg-background text-foreground">
      <.marketing_header current_path={@current_path} />
      <Nav.primary_nav_modals :if={@show_nav_modals} />
      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>
      <.marketing_footer />
    </div>
    """
  end

  attr :current_path, :string, default: "/"

  def marketing_header(assigns) do
    ~H"""
    <header class="sticky top-0 z-50 bg-background/80 backdrop-blur-md pt-6 pb-12" id="main-header" phx-hook="ScrollShrink">
      <Nav.primary_nav
        current_path={@current_path}
        layout_mode={:constrained}
        mobile_menu_id="marketing-primary-mobile-menu"
      />
    </header>
    """
  end

  def marketing_footer(assigns) do
    assigns =
      assigns
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

            <button
              id="theme-toggle-btn"
              phx-hook="ThemeToggle"
              aria-label="Toggle theme"
              class="inline-flex h-8 w-8 items-center justify-center rounded border border-border bg-surface text-muted-foreground transition-colors hover:text-foreground hover:border-foreground/40 mb-4"
            >
              <svg
                data-theme-icon="moon"
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.75"
                  d="M21 12.79A9 9 0 1 1 11.21 3c0 .45.05.89.14 1.31A7 7 0 0 0 19.69 12.65c.44.09.87.14 1.31.14Z"
                />
              </svg>
              <svg
                data-theme-icon="sun"
                xmlns="http://www.w3.org/2000/svg"
                class="hidden h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.75"
                  d="M12 3v2.25m0 13.5V21m6.364-15.364-1.591 1.591M7.227 16.773l-1.591 1.591M21 12h-2.25M5.25 12H3m15.364 6.364-1.591-1.591M7.227 7.227 5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z"
                />
              </svg>
            </button>

            <div class="text-muted-foreground text-xs space-y-1">
              <p>Made with ❤️ for the BEAM</p>
              <p>Copyright © 2025-> Mike Hostetler</p>
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
            <span>Apache License 2.0</span>
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
