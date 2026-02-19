defmodule AgentJidoWeb.Jido.DocsComponents do
  @moduledoc """
  Documentation-specific components for the Jido docs site.
  """
  use AgentJidoWeb, :html

  alias AgentJidoWeb.Jido.Nav

  attr(:current_path, :string, default: nil)

  def docs_header(assigns) do
    ~H"""
    <header class="z-40 border-b border-border bg-background/90 backdrop-blur-md">
      <Nav.primary_nav
        current_path={@current_path}
        layout_mode={:fluid}
        surface_mode={:flush}
        show_theme_toggle={true}
        mobile_menu_id="docs-primary-mobile-menu"
      />
    </header>
    """
  end

  # Secondary Navigation Component
  attr(:current_path, :string, default: nil)
  attr(:tabs, :list, default: [])

  def docs_secondary_nav(assigns) do
    ~H"""
    <div class="border-b border-border bg-card/50 px-6">
      <nav class="docs-scrollbar flex min-w-0 items-center gap-1 overflow-x-auto overflow-y-hidden">
        <%= for tab <- @tabs do %>
          <%= if tab[:external] do %>
            <a
              href={tab.href}
              target="_blank"
              rel="noopener noreferrer"
              class="flex items-center gap-1 px-4 py-3 text-[13px] whitespace-nowrap transition-colors border-b-2 -mb-[1px] text-muted-foreground border-b-transparent hover:text-foreground hover:border-b-border"
            >
              {tab.label}
              <.icon name="hero-arrow-top-right-on-square" class="h-3 w-3" />
            </a>
          <% else %>
            <.link
              navigate={tab.href}
              class={
                "flex items-center gap-1 px-4 py-3 text-[13px] whitespace-nowrap transition-colors border-b-2 -mb-[1px] " <>
                if Enum.any?(Map.get(tab, :active_paths, [tab.href]), &String.starts_with?(@current_path || "", &1)) do
                  "text-foreground font-medium border-b-primary"
                else
                  "text-muted-foreground border-b-transparent hover:text-foreground hover:border-b-border"
                end
              }
            >
              {tab.label}
            </.link>
          <% end %>
        <% end %>
      </nav>
    </div>
    """
  end

  # Left Sidebar Component
  attr(:nav, :list, required: true)
  attr(:current_path, :string, default: nil)
  attr(:open, :boolean, default: true)

  def docs_sidebar(assigns) do
    ~H"""
    <%= if @open do %>
      <aside class="docs-scrollbar hidden lg:block h-full w-[260px] shrink-0 overflow-y-auto border-r border-border bg-card">
        <div class="py-4">
          <!-- Jido Docs header -->
          <div class="flex items-center justify-between px-4 mb-4">
            <.link navigate="/docs" class="flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors">
              <.icon name="hero-home" class="h-4 w-4" /> Jido Docs
            </.link>
            <button
              phx-click="toggle_sidebar"
              class="p-1.5 rounded-md text-muted-foreground hover:text-foreground hover:bg-elevated transition-colors"
              title="Collapse sidebar"
            >
              <.icon name="hero-chevron-left" class="h-4 w-4" />
            </button>
          </div>

          <%= for section <- @nav do %>
            <details class="mb-2 group" open>
              <summary class="list-none w-full flex items-center justify-between px-4 py-2.5 text-[12px] font-bold tracking-[0.05em] uppercase text-foreground hover:text-primary transition-colors cursor-pointer [&::-webkit-details-marker]:hidden">
                <span>{section.title}</span>
                <.icon name="hero-chevron-down" class="h-3.5 w-3.5 text-muted-foreground transition-transform group-open:rotate-180" />
              </summary>

              <div class="mt-1">
                <%= for item <- section.items do %>
                  <%= if item[:external] do %>
                    <a
                      href={item.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      class={
                        "flex items-center justify-between px-4 py-2 ml-2 text-[13px] transition-all duration-150 border-l-2 " <>
                        "border-l-border text-muted-foreground hover:text-foreground hover:bg-elevated hover:border-l-muted-foreground"
                      }
                    >
                      <span>{item.label}</span>
                      <%= if item[:badge] do %>
                        <span class={
                          "text-[9px] font-semibold tracking-wide px-1.5 py-0.5 rounded " <>
                          badge_class(item.badge)
                        }>
                          {item.badge}
                        </span>
                      <% end %>
                    </a>
                  <% else %>
                    <.link
                      navigate={item.href}
                      class={
                        "flex items-center justify-between px-4 py-2 ml-2 text-[13px] transition-all duration-150 border-l-2 " <>
                        if @current_path == item.href do
                          "border-l-primary bg-primary/5 text-primary font-medium"
                        else
                          "border-l-border text-muted-foreground hover:text-foreground hover:bg-elevated hover:border-l-muted-foreground"
                        end
                      }
                    >
                      <span>{item.label}</span>
                      <%= if item[:badge] do %>
                        <span class={
                          "text-[9px] font-semibold tracking-wide px-1.5 py-0.5 rounded " <>
                          badge_class(item.badge)
                        }>
                          {item.badge}
                        </span>
                      <% end %>
                    </.link>
                  <% end %>
                <% end %>
              </div>
            </details>
          <% end %>
        </div>
      </aside>
    <% else %>
      <aside class="docs-scrollbar hidden lg:flex h-full w-[56px] shrink-0 flex-col overflow-y-auto border-r border-border bg-card">
        <button
          phx-click="toggle_sidebar"
          class="m-3 p-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground transition-colors"
          title="Expand sidebar"
        >
          <.icon name="hero-chevron-right" class="h-4 w-4" />
        </button>

        <.link
          navigate="/docs"
          class="mx-3 p-2 rounded-md text-muted-foreground hover:text-primary hover:bg-primary/10 transition-colors"
          title="Jido Docs"
        >
          <.icon name="hero-home" class="h-4 w-4" />
        </.link>
      </aside>
    <% end %>
    """
  end

  # Right Sidebar Component
  attr(:toc, :list, default: nil)

  def docs_right_sidebar(assigns) do
    ~H"""
    <aside class="hidden xl:flex h-full w-[200px] shrink-0 flex-col border-l border-border bg-background/40 px-5 py-12">
      <%= if @toc && @toc != [] do %>
        <div class="mb-8 flex min-h-0 flex-1 flex-col">
          <div class="text-[10px] font-bold tracking-[0.1em] uppercase text-muted-foreground mb-4">
            ON THIS PAGE
          </div>
          <nav class="docs-scrollbar min-h-0 flex-1 space-y-0 overflow-y-auto pr-1">
            <%= for item <- @toc do %>
              <a
                href={"##{item.id}"}
                class="block text-[11px] py-1.5 transition-colors border-l-2 pl-3 -ml-px text-muted-foreground border-l-transparent hover:text-foreground hover:border-l-muted-foreground"
              >
                {item.title}
              </a>
            <% end %>
          </nav>
        </div>
      <% else %>
        <div class="flex-1" />
      <% end %>
      
    <!-- Quick Links -->
      <div class="shrink-0 p-4 rounded-md bg-card border border-border">
        <div class="text-[10px] font-semibold text-muted-foreground mb-2">
          QUICK LINKS
        </div>
        <div class="flex flex-col gap-2">
          <%= for {label, icon, href} <- [
            {"HexDocs", "◇", Nav.hexdocs_url()},
            {"GitHub", "◈", Nav.github_url()},
            {"Hex.pm", "⬡", Nav.hex_url()}
          ] do %>
            <a
              href={href}
              target="_blank"
              rel="noopener noreferrer"
              class="text-[11px] text-muted-foreground flex items-center gap-1.5 hover:text-primary transition-colors"
            >
              <span>{icon}</span>
              <span>{label}</span>
            </a>
          <% end %>
        </div>
      </div>
    </aside>
    """
  end

  # Numbered Card Component
  attr(:number, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, required: true)
  attr(:href, :string, required: true)

  def numbered_card(assigns) do
    ~H"""
    <.link navigate={@href} class="block group">
      <div class="bg-card border border-border rounded-md p-5 flex gap-4 items-start transition-all duration-200 hover:border-primary hover:-translate-y-0.5">
        <div class="w-8 h-8 rounded-md flex-shrink-0 flex items-center justify-center bg-primary/15 text-primary font-bold text-sm">
          {@number}
        </div>
        <div>
          <div class="text-sm font-semibold text-foreground mb-1 group-hover:text-primary transition-colors">
            {@title}
          </div>
          <p class="text-xs text-muted-foreground leading-relaxed">
            {@description}
          </p>
        </div>
      </div>
    </.link>
    """
  end

  # Icon Card Component
  attr(:icon, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, required: true)
  attr(:color, :string, default: "green")
  attr(:href, :string, required: true)

  def icon_card(assigns) do
    ~H"""
    <.link navigate={@href} class="block group h-full">
      <div class={
        "bg-card border border-border rounded-md p-5 h-full transition-all duration-200 hover:-translate-y-0.5 " <>
        icon_card_color_class(@color)
      }>
        <div class={"text-2xl mb-3 font-mono " <> icon_text_color_class(@color)}>
          {@icon}
        </div>
        <div class="text-sm font-semibold text-foreground mb-2">
          {@title}
        </div>
        <p class="text-xs text-muted-foreground leading-relaxed">
          {@description}
        </p>
      </div>
    </.link>
    """
  end

  # Helper functions for color classes
  defp badge_class("CORE"), do: "bg-primary/15 text-primary"
  defp badge_class("AI"), do: "bg-accent-yellow/15 text-accent-yellow"
  defp badge_class("APP"), do: "bg-accent-red/15 text-accent-red"
  defp badge_class("FOUNDATION"), do: "bg-accent-cyan/15 text-accent-cyan"
  defp badge_class(_), do: "bg-muted text-muted-foreground"

  defp icon_card_color_class("green"), do: "hover:border-accent-green"
  defp icon_card_color_class("yellow"), do: "hover:border-accent-yellow"
  defp icon_card_color_class("cyan"), do: "hover:border-accent-cyan"
  defp icon_card_color_class("red"), do: "hover:border-accent-red"
  defp icon_card_color_class(_), do: "hover:border-border"

  defp icon_text_color_class("green"), do: "text-accent-green"
  defp icon_text_color_class("yellow"), do: "text-accent-yellow"
  defp icon_text_color_class("cyan"), do: "text-accent-cyan"
  defp icon_text_color_class("red"), do: "text-accent-red"
  defp icon_text_color_class(_), do: "text-primary"
end
