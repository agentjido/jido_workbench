defmodule AgentJidoWeb.Jido.Nav do
  @moduledoc """
  Shared navigation constants and icon components used across marketing,
  docs, and (legacy) workbench headers/footers.
  """
  use AgentJidoWeb, :html

  @jido_version "v0.1.0"

  @marketing_nav_links [
    {"Ecosystem", "/ecosystem"},
    {"Features", "/features"},
    {"Examples", "/examples"},
    {"Training", "/training"},
    {"Docs", "/docs"}
  ]

  @docs_nav_links ["/docs", "/examples", "/training", "/ecosystem"]

  @footer_company_links [
    {"Blog", "/blog"},
    {"Features", "/features"}
  ]

  @footer_resource_links [
    {"Docs", "/docs"},
    {"Examples", "/examples"},
    {"Training", "/training"}
  ]

  @footer_package_links [
    {"Hex", "https://hex.pm/packages/jido"},
    {"HexDocs", "https://hexdocs.pm/jido"},
    {"jido", "https://hex.pm/packages/jido"},
    {"jido_ai", "https://hex.pm/packages/jido_ai"},
    {"req_llm", "https://hex.pm/packages/req_llm"}
  ]

  @social_links [
    {:discord, "Discord", "https://discord.gg/jido"},
    {:github, "GitHub", "https://github.com/agentjido/jido"},
    {:x, "x.com", "https://x.com/agentjido"},
    {:linkedin, "LinkedIn", "https://linkedin.com/company/jido"},
    {:youtube, "YouTube", "https://youtube.com/@agentjido"}
  ]

  @github_url "https://github.com/agentjido/jido"
  @hex_url "https://hex.pm/packages/jido"
  @hexdocs_url "https://hexdocs.pm/jido"
  @discord_url "https://discord.gg/jido"

  def marketing_nav_links, do: @marketing_nav_links
  def docs_nav_links, do: @docs_nav_links
  def footer_company_links, do: @footer_company_links
  def footer_resource_links, do: @footer_resource_links
  def footer_package_links, do: @footer_package_links
  def social_links, do: @social_links
  def github_url, do: @github_url
  def hex_url, do: @hex_url
  def hexdocs_url, do: @hexdocs_url
  def discord_url, do: @discord_url
  def jido_version, do: @jido_version

  @doc "Jido logo mark — gradient J block + JIDO text."
  attr :class, :string, default: ""
  attr :logo_size, :string, default: "w-7 h-7 text-sm"
  attr :text_size, :string, default: "text-base"
  attr :show_version, :boolean, default: true

  def logo(assigns) do
    ~H"""
    <.link navigate="/" class={"flex items-center gap-2.5 #{@class}"}>
      <div class={"rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow transition-all duration-300 #{@logo_size}"}>
        J
      </div>
      <span class={"font-bold tracking-wide transition-all duration-300 #{@text_size}"}>JIDO</span>
      <span :if={@show_version} class="text-muted-foreground text-[11px] ml-1">{jido_version()}</span>
    </.link>
    """
  end

  attr :class, :string, default: "w-4 h-4"

  def discord_icon(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="currentColor">
      <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z" />
    </svg>
    """
  end

  attr :class, :string, default: "w-4 h-4"

  def github_icon(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
    """
  end

  attr :class, :string, default: "w-4 h-4"

  def x_icon(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="currentColor">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
    """
  end

  attr :class, :string, default: "w-4 h-4"

  def linkedin_icon(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="currentColor">
      <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
    </svg>
    """
  end

  attr :class, :string, default: "w-4 h-4"

  def youtube_icon(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="currentColor">
      <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
    </svg>
    """
  end

  @doc "Renders the appropriate social icon for a given key."
  attr :icon, :atom, required: true
  attr :class, :string, default: "w-4 h-4"

  def social_icon(assigns) do
    ~H"""
    <%= case @icon do %>
      <% :discord -> %>
        <.discord_icon class={@class} />
      <% :github -> %>
        <.github_icon class={@class} />
      <% :x -> %>
        <.x_icon class={@class} />
      <% :linkedin -> %>
        <.linkedin_icon class={@class} />
      <% :youtube -> %>
        <.youtube_icon class={@class} />
      <% _ -> %>
        <span />
    <% end %>
    """
  end
end
