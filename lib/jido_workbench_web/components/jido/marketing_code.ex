defmodule JidoWorkbenchWeb.Jido.MarketingCode do
  @moduledoc """
  Code block components for Jido marketing pages.
  """
  use JidoWorkbenchWeb, :html

  attr :title, :string, default: nil
  attr :language, :string, default: "elixir"
  attr :code, :string, required: true
  attr :class, :string, default: ""

  def code_block(assigns) do
    ~H"""
    <div class={"code-block #{@class}"}>
      <%= if @title do %>
        <div class="code-header">
          <div class="flex gap-2">
            <span class="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-accent-green"></span>
          </div>
          <span class="text-[10px] text-muted-foreground"><%= @title %></span>
        </div>
      <% end %>
      <pre class="p-5 text-[11px] leading-relaxed overflow-x-auto"><code class={"language-#{@language}"}><%= @code %></code></pre>
    </div>
    """
  end

  attr :command, :string, required: true
  attr :class, :string, default: ""

  def terminal_command(assigns) do
    ~H"""
    <div class={"code-block #{@class}"}>
      <div class="code-header">
        <div class="flex gap-2">
          <span class="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
          <span class="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
          <span class="w-2.5 h-2.5 rounded-full bg-accent-green"></span>
        </div>
        <span class="text-[10px] text-muted-foreground">terminal</span>
      </div>
      <div class="p-5 text-[11px] leading-relaxed">
        <span class="text-primary">$</span>
        <span class="text-foreground ml-2"><%= @command %></span>
      </div>
    </div>
    """
  end

  attr :steps, :list, required: true
  attr :class, :string, default: ""

  def install_steps(assigns) do
    ~H"""
    <div class={"space-y-4 #{@class}"}>
      <%= for {step, index} <- Enum.with_index(@steps, 1) do %>
        <div class="flex gap-4 items-start">
          <div class="w-6 h-6 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xs font-bold shrink-0">
            <%= index %>
          </div>
          <div class="flex-1">
            <p class="text-sm font-medium text-foreground mb-2"><%= step.title %></p>
            <%= if step[:code] do %>
              <.terminal_command command={step.code} />
            <% end %>
            <%= if step[:description] do %>
              <p class="text-xs text-muted-foreground mt-2"><%= step.description %></p>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
