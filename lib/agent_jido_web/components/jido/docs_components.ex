defmodule AgentJidoWeb.Jido.DocsComponents do
  @moduledoc """
  Documentation-specific components for the Jido docs site.
  """
  use AgentJidoWeb, :html

  alias AgentJidoWeb.Jido.Nav

  attr :current_path, :string, default: nil

  def docs_header(assigns) do
    assigns = assign(assigns, :nav_links, Nav.docs_nav_links())

    ~H"""
    <nav class="flex items-center justify-between px-6 py-4 bg-card border-b border-border sticky top-0 z-50">
      <div class="flex items-center gap-6">
        <Nav.logo show_version={false} />
        <span class="text-[11px] text-muted-foreground px-2 py-0.5 bg-elevated rounded -ml-2">
          Docs
        </span>

        <div class="hidden md:flex items-center gap-5">
          <%= for item <- @nav_links do %>
            <.link
              navigate={item}
              class={"text-xs transition-colors #{if @current_path && String.starts_with?(@current_path, item), do: "text-primary font-semibold", else: "text-muted-foreground hover:text-foreground"}"}
            >
              {String.replace_prefix(item, "/", "")}
            </.link>
          <% end %>
        </div>
      </div>

      <div class="flex items-center gap-3">
        <div class="hidden md:flex items-center gap-2 bg-elevated border border-border rounded px-3 py-2 min-w-[200px] cursor-pointer hover:border-muted-foreground transition-colors">
          <.icon name="hero-magnifying-glass" class="h-3 w-3 text-muted-foreground" />
          <span class="text-xs text-muted-foreground flex-1">Search...</span>
          <kbd class="text-[10px] text-muted-foreground px-1.5 py-0.5 bg-card border border-border rounded">
            ⌘K
          </kbd>
        </div>

        <button class="hidden md:flex items-center gap-2 bg-primary/10 border border-primary/30 rounded px-3 py-2 text-xs text-primary font-medium hover:bg-primary/20 transition-colors">
          <.icon name="hero-sparkles" class="h-3 w-3" /> Ask AI
        </button>

        <a
          href={Nav.github_url()}
          target="_blank"
          rel="noopener noreferrer"
          class="text-xs text-muted-foreground hover:text-foreground transition-colors"
        >
          GitHub
        </a>
        <a
          href={Nav.hex_url()}
          target="_blank"
          rel="noopener noreferrer"
          class="text-xs text-muted-foreground hover:text-foreground transition-colors"
        >
          Hex
        </a>
      </div>
    </nav>
    """
  end

  # Secondary Navigation Component
  attr :current_path, :string, default: nil

  def docs_secondary_nav(assigns) do
    ~H"""
    <div class="border-b border-border bg-card/50 px-6 overflow-x-auto">
      <nav class="flex items-center gap-1">
        <%= for tab <- [
          %{label: "Get started", href: "/docs", active_paths: ["/docs", "/docs/installation", "/docs/quickstart", "/docs/concepts", "/docs/production-checklist"]},
          %{label: "Packages", href: "/docs/packages/jido", active_paths: ["/docs/packages"]},
          %{label: "Agents", href: "/docs/agents/defining", active_paths: ["/docs/agents"]},
          %{label: "Actions", href: "/docs/actions/schemas", active_paths: ["/docs/actions", "/docs/signals"]},
          %{label: "AI & LLMs", href: "/docs/ai/llm-config", active_paths: ["/docs/ai"]},
          %{label: "Production", href: "/docs/production/deployment", active_paths: ["/docs/production"]},
          %{label: "Reference", href: "/docs/reference/cli", active_paths: ["/docs/reference"]}
        ] do %>
          <.link
            navigate={tab.href}
            class={
              "flex items-center gap-1 px-4 py-3 text-[13px] whitespace-nowrap transition-colors border-b-2 -mb-[1px] " <>
              if Enum.any?(tab.active_paths, &String.starts_with?(@current_path || "", &1)) do
                "text-foreground font-medium border-b-primary"
              else
                "text-muted-foreground border-b-transparent hover:text-foreground hover:border-b-border"
              end
            }
          >
            {tab.label}
          </.link>
        <% end %>
      </nav>
    </div>
    """
  end

  # Left Sidebar Component
  attr :nav, :list, required: true
  attr :current_path, :string, default: nil
  attr :open, :boolean, default: true

  def docs_sidebar(assigns) do
    ~H"""
    <%= if @open do %>
      <aside class="hidden lg:block w-[260px] shrink-0 bg-card border-r border-border overflow-y-auto sticky top-[105px] h-[calc(100vh-105px)]">
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
            <div class="mb-2">
              <div class="w-full flex items-center justify-between px-4 py-2.5 text-[12px] font-bold tracking-[0.05em] uppercase text-foreground hover:text-primary transition-colors cursor-pointer">
                <span>{section.title}</span>
                <.icon name="hero-chevron-down" class="h-3.5 w-3.5 text-muted-foreground" />
              </div>

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
            </div>
          <% end %>
        </div>
      </aside>
    <% else %>
      <aside class="hidden lg:flex flex-col w-[56px] shrink-0 bg-card border-r border-border sticky top-[105px] h-[calc(100vh-105px)]">
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
  attr :toc, :list, default: nil

  def docs_right_sidebar(assigns) do
    ~H"""
    <aside class="hidden xl:block w-[200px] shrink-0 sticky top-[105px] h-[calc(100vh-105px)] py-12 px-5 overflow-y-auto">
      <%= if @toc && @toc != [] do %>
        <div class="mb-8">
          <div class="text-[10px] font-bold tracking-[0.1em] uppercase text-muted-foreground mb-4">
            ON THIS PAGE
          </div>
          <nav class="space-y-0">
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
      <% end %>
      
    <!-- Quick Links -->
      <div class="p-4 rounded-md bg-card border border-border">
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
  attr :number, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :href, :string, required: true

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
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :color, :string, default: "green"
  attr :href, :string, required: true

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
