defmodule JidoWorkbenchWeb.Jido.UI do
  @moduledoc """
  Reusable UI primitive components for the Jido design system.
  """
  use JidoWorkbenchWeb, :html

  # Button component with variants
  attr :variant, :string, default: "primary", values: ["primary", "outline", "ghost", "secondary"]
  attr :size, :string, default: "md", values: ["sm", "md", "lg"]
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value type)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex items-center justify-center rounded-md font-medium transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:pointer-events-none disabled:opacity-50",
        button_variant_class(@variant),
        button_size_class(@size),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp button_variant_class("outline"), do: "bg-transparent border-2 border-border text-foreground hover:bg-surface"
  defp button_variant_class("ghost"), do: "bg-transparent border-transparent text-muted-foreground hover:bg-surface hover:text-foreground"
  defp button_variant_class("secondary"), do: "bg-secondary text-secondary-foreground border border-border hover:bg-secondary/80"
  defp button_variant_class(_primary), do: "bg-primary text-primary-foreground border-transparent hover:bg-primary/90"

  defp button_size_class("sm"), do: "h-8 px-3 text-xs"
  defp button_size_class("lg"), do: "h-11 px-6 text-sm"
  defp button_size_class(_md), do: "h-9 px-4 text-[13px]"

  # Badge component for layer indicators
  attr :kind, :atom, default: :core, values: [:core, :ai, :foundation, :app]
  attr :class, :string, default: ""
  slot :inner_block

  def badge(assigns) do
    ~H"""
    <span class={["badge-#{@kind}", @class]}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= String.upcase(to_string(@kind)) %>
      <% end %>
    </span>
    """
  end

  # Code block with header
  attr :title, :string, default: nil
  attr :language, :string, default: "elixir"
  attr :show_copy, :boolean, default: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def code_block(assigns) do
    ~H"""
    <div class={["code-block overflow-hidden", @class]}>
      <%= if @title do %>
        <div class="code-header">
          <span class="text-muted-foreground text-xs"><%= @title %></span>
          <div class="flex items-center gap-3">
            <span class="text-muted-foreground text-[10px] uppercase tracking-widest"><%= @language %></span>
            <%= if @show_copy do %>
              <button
                phx-hook="CopyCode"
                id={"copy-#{:erlang.phash2(@title)}"}
                class="bg-surface border border-border text-secondary-foreground px-3 py-1 rounded text-[10px] hover:text-foreground transition-colors"
              >
                COPY
              </button>
            <% end %>
          </div>
        </div>
      <% end %>
      <div class="p-5 overflow-x-auto">
        <pre class="text-[13px] leading-relaxed"><%= render_slot(@inner_block) %></pre>
      </div>
    </div>
    """
  end

  # Icon card
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon_color, :string, default: "text-primary"
  attr :href, :string, default: nil
  attr :class, :string, default: ""

  def icon_card(assigns) do
    ~H"""
    <%= if @href do %>
      <.link navigate={@href} class={["icon-card block cursor-pointer", @class]}>
        <div class={"text-2xl mb-3 #{@icon_color}"}><%= @icon %></div>
        <div class="font-bold text-[13px] mb-2 text-foreground"><%= @title %></div>
        <p class="text-muted-foreground text-xs leading-relaxed"><%= @description %></p>
      </.link>
    <% else %>
      <div class={["icon-card", @class]}>
        <div class={"text-2xl mb-3 #{@icon_color}"}><%= @icon %></div>
        <div class="font-bold text-[13px] mb-2 text-foreground"><%= @title %></div>
        <p class="text-muted-foreground text-xs leading-relaxed"><%= @description %></p>
      </div>
    <% end %>
    """
  end

  # Numbered card for steps
  attr :number, :integer, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :href, :string, default: nil
  attr :class, :string, default: ""

  def numbered_card(assigns) do
    number_colors = %{
      1 => "text-accent-green border-accent-green/30",
      2 => "text-accent-yellow border-accent-yellow/30",
      3 => "text-accent-cyan border-accent-cyan/30",
      4 => "text-accent-red border-accent-red/30"
    }
    
    color_class = Map.get(number_colors, assigns.number, "text-primary border-primary/30")
    assigns = assign(assigns, :color_class, color_class)
    
    ~H"""
    <%= if @href do %>
      <.link navigate={@href} class={["numbered-card block cursor-pointer hover:border-border-strong transition-colors", @class]}>
        <div class="flex items-start gap-4">
          <div class={"w-8 h-8 rounded-full border flex items-center justify-center text-sm font-bold #{@color_class}"}>
            <%= @number %>
          </div>
          <div class="flex-1">
            <div class="font-bold text-[13px] mb-1 text-foreground"><%= @title %></div>
            <p class="text-muted-foreground text-xs leading-relaxed"><%= @description %></p>
          </div>
        </div>
      </.link>
    <% else %>
      <div class={["numbered-card", @class]}>
        <div class="flex items-start gap-4">
          <div class={"w-8 h-8 rounded-full border flex items-center justify-center text-sm font-bold #{@color_class}"}>
            <%= @number %>
          </div>
          <div class="flex-1">
            <div class="font-bold text-[13px] mb-1 text-foreground"><%= @title %></div>
            <p class="text-muted-foreground text-xs leading-relaxed"><%= @description %></p>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  # Quickstart card with emoji
  attr :emoji, :string, required: true
  attr :title, :string, required: true
  attr :href, :string, default: nil
  attr :class, :string, default: ""

  def quickstart_card(assigns) do
    ~H"""
    <%= if @href do %>
      <.link navigate={@href} class={["quickstart-card cursor-pointer", @class]}>
        <span class="text-xl"><%= @emoji %></span>
        <span class="text-sm font-medium text-foreground"><%= @title %></span>
      </.link>
    <% else %>
      <div class={["quickstart-card", @class]}>
        <span class="text-xl"><%= @emoji %></span>
        <span class="text-sm font-medium text-foreground"><%= @title %></span>
      </div>
    <% end %>
    """
  end

  # Section header with optional link
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :link_text, :string, default: nil
  attr :link_href, :string, default: nil

  def section_header(assigns) do
    ~H"""
    <div class="flex justify-between items-center mb-6">
      <div>
        <span class="font-bold text-sm tracking-wider"><%= @title %></span>
        <%= if @subtitle do %>
          <span class="text-muted-foreground text-xs ml-4"><%= @subtitle %></span>
        <% end %>
      </div>
      <%= if @link_text && @link_href do %>
        <.link navigate={@link_href} class="text-primary text-xs hover:underline">
          <%= @link_text %>
        </.link>
      <% end %>
    </div>
    """
  end
end
