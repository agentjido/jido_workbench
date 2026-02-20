defmodule AgentJidoWeb.Jido.MarketingCards do
  @moduledoc """
  Card components for Jido marketing pages.
  """
  use AgentJidoWeb, :html

  attr :name, :string, required: true
  attr :desc, :string, required: true
  attr :layer, :atom, values: [:core, :ai, :foundation, :app], required: true
  attr :path, :string, default: nil
  attr :links, :map, default: %{}

  def package_card(assigns) do
    ~H"""
    <div class={"package-card-#{@layer} relative group hover:-translate-y-0.5 transition-transform duration-200 #{if @path, do: "cursor-pointer", else: ""}"}>
      <.link
        :if={@path}
        navigate={@path}
        aria-label={"View #{@name} package details"}
        class="absolute inset-0 z-10 rounded-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
      >
        <span class="sr-only">View {@name} package details</span>
      </.link>

      <div class="flex justify-between items-start mb-3">
        <span class="text-sm font-bold text-foreground group-hover:text-primary transition-colors">{@name}</span>
        <.layer_badge layer={@layer} />
      </div>
      <p class="text-xs text-muted-foreground leading-relaxed mb-4">{@desc}</p>

      <div class="relative z-20 flex gap-2 flex-wrap">
        <%= if @path do %>
          <.link navigate={@path} class="text-[10px] px-2 py-1 rounded bg-primary/10 text-primary hover:bg-primary/15 transition-colors">
            details
          </.link>
        <% end %>
        <%= for {label, href} <- @links do %>
          <a href={href} target="_blank" class="text-[10px] px-2 py-1 rounded bg-elevated text-muted-foreground hover:text-primary transition-colors">
            {label}
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  attr :layer, :atom, values: [:core, :ai, :foundation, :app], required: true

  def layer_badge(assigns) do
    ~H"""
    <span class={"badge-#{@layer} uppercase"}>{@layer}</span>
    """
  end

  attr :value, :string, required: true
  attr :label, :string, required: true
  attr :color_class, :string, default: "text-accent-green"

  def metric_card(assigns) do
    ~H"""
    <div class="metric-card rounded-md">
      <div class={"text-xl sm:text-[22px] font-bold #{@color_class}"}>
        {@value}
      </div>
      <div class="text-[10px] text-muted-foreground uppercase tracking-wider mt-1.5">
        {@label}
      </div>
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true

  def feature_card(assigns) do
    ~H"""
    <div class={"feature-card #{@class}"}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, default: nil
  attr :class, :string, default: ""

  def info_card(assigns) do
    ~H"""
    <div class={"bg-card border border-border rounded-md p-6 #{@class}"}>
      <%= if @icon do %>
        <div class="text-primary mb-3 text-2xl">{@icon}</div>
      <% end %>
      <h3 class="text-sm font-bold text-foreground mb-2">{@title}</h3>
      <p class="text-xs text-muted-foreground leading-relaxed">{@description}</p>
    </div>
    """
  end
end
