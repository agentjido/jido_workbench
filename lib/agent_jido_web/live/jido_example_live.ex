defmodule AgentJidoWeb.JidoExampleLive do
  @moduledoc """
  Show page for an individual interactive example.

  Renders the example's markdown explanation, syntax-highlighted source code,
  and an embedded LiveView running the actual interactive demo.

  Tabs are URL-driven via hash params so the URL changes as users navigate.
  Source code is syntax-highlighted at compile time via Makeup and embedded
  in the Example struct.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Examples

  @valid_tabs ~w(demo explanation source)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug} = params, _uri, socket) do
    example = Examples.get_example!(slug)

    demo_module =
      example.live_view_module
      |> String.split(".")
      |> Module.safe_concat()

    tab =
      case Map.get(params, "tab") do
        tab when tab in @valid_tabs -> String.to_existing_atom(tab)
        _ -> :explanation
      end

    active_source =
      case Map.get(params, "file") do
        nil -> List.first(example.sources)
        file -> Enum.find(example.sources, List.first(example.sources), &(&1.path == file))
      end

    {:noreply,
     socket
     |> assign(:example, example)
     |> assign(:demo_module, demo_module)
     |> assign(:active_tab, tab)
     |> assign(:active_source, active_source)
     |> assign(:page_title, example.title)
     |> assign(:meta_description, example.description)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/examples">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <%!-- Back link --%>
        <div class="mb-8">
          <.link
            navigate="/examples"
            class="text-xs text-muted-foreground hover:text-primary transition-colors"
          >
            ← back to examples
          </.link>
        </div>

        <%!-- Header --%>
        <section class="mb-10">
          <div class="flex flex-wrap items-center gap-3 mb-3">
            <span class="text-2xl">{@example.emoji}</span>
            <span class={"text-[10px] px-2 py-1 rounded font-semibold uppercase tracking-wider #{category_class(@example.category)}"}>
              {@example.category}
            </span>
            <span class={"text-[10px] px-2 py-1 rounded font-semibold uppercase tracking-wider #{difficulty_class(@example.difficulty)}"}>
              {@example.difficulty}
            </span>
          </div>

          <h1 class="text-3xl font-bold tracking-tight mb-3">{@example.title}</h1>
          <p class="text-sm text-secondary-foreground leading-relaxed max-w-[820px]">
            {@example.description}
          </p>

          <div class="flex gap-2 mt-4 flex-wrap">
            <%= for tag <- @example.tags do %>
              <span class="text-[10px] px-2 py-1 rounded bg-elevated border border-border text-muted-foreground">
                {tag}
              </span>
            <% end %>
          </div>
        </section>

        <%!-- Tab navigation --%>
        <div class="flex gap-1 mb-6 border-b border-border">
          <.tab_link
            slug={@example.slug}
            tab="explanation"
            active_tab={@active_tab}
            label="Explanation"
          />
          <.tab_link slug={@example.slug} tab="demo" active_tab={@active_tab} label="Interactive Demo" />
          <.tab_link
            slug={@example.slug}
            tab="source"
            active_tab={@active_tab}
            label="Source Code"
          />
        </div>

        <%!-- Demo tab --%>
        <div :if={@active_tab == :demo} class="mb-10">
          {live_render(@socket, @demo_module, id: "demo-#{@example.slug}")}
        </div>

        <%!-- Explanation tab --%>
        <div :if={@active_tab == :explanation} class="mb-10">
          <article class="prose prose-invert max-w-none text-sm leading-relaxed">
            {Phoenix.HTML.raw(@example.body)}
          </article>
        </div>

        <%!-- Source code tab --%>
        <div :if={@active_tab == :source} class="mb-10">
          <%!-- Source file selector --%>
          <div :if={length(@example.sources) > 1} class="flex gap-1 mb-4 flex-wrap">
            <%= for src <- @example.sources do %>
              <.link
                patch={~p"/examples/#{@example.slug}?tab=source&file=#{src.path}"}
                class={"text-xs px-3 py-2 rounded transition-colors #{if @active_source && @active_source.path == src.path, do: "bg-primary/10 text-primary border border-primary/30", else: "bg-elevated text-muted-foreground hover:text-foreground border border-border"}"}
              >
                {Path.basename(src.path)}
              </.link>
            <% end %>
          </div>

          <div :if={@active_source} class="rounded-lg border border-border bg-card overflow-hidden">
            <div class="px-4 py-2 border-b border-border bg-elevated flex items-center justify-between">
              <span class="text-[11px] font-mono text-muted-foreground">{@active_source.path}</span>
              <span class="text-[10px] text-muted-foreground/50">
                {String.split(@active_source.content, "\n") |> length()} lines
              </span>
            </div>
            <div class="p-4 overflow-x-auto">
              <div class="text-[12px] leading-relaxed">
                {Phoenix.HTML.raw(@active_source.highlighted)}
              </div>
            </div>
          </div>

          <div
            :if={@active_source == nil}
            class="rounded-lg border border-border bg-card p-8 text-center"
          >
            <p class="text-sm text-muted-foreground">
              No source files configured for this example.
            </p>
          </div>
        </div>
      </div>
    </.marketing_layout>
    """
  end

  # ── Components ──────────────────────────────────────────────

  attr :slug, :string, required: true
  attr :tab, :string, required: true
  attr :active_tab, :atom, required: true
  attr :label, :string, required: true

  defp tab_link(assigns) do
    active = assigns.active_tab == String.to_existing_atom(assigns.tab)
    assigns = assign(assigns, :active, active)

    ~H"""
    <.link
      patch={~p"/examples/#{@slug}?tab=#{@tab}"}
      class={"px-4 py-2 text-sm font-semibold transition-colors border-b-2 -mb-px #{if @active, do: "border-primary text-primary", else: "border-transparent text-muted-foreground hover:text-foreground"}"}
    >
      {@label}
    </.link>
    """
  end

  # ── Helpers ─────────────────────────────────────────────────

  defp category_class(:core),
    do: "bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan"

  defp category_class(:ai),
    do: "bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow"

  defp category_class(:production),
    do: "bg-primary/10 border border-primary/30 text-primary"

  defp category_class(_), do: "bg-elevated border border-border text-muted-foreground"

  defp difficulty_class(:beginner),
    do: "bg-green-500/10 border border-green-500/30 text-green-400"

  defp difficulty_class(:intermediate),
    do: "bg-amber-500/10 border border-amber-500/30 text-amber-400"

  defp difficulty_class(:advanced),
    do: "bg-red-500/10 border border-red-500/30 text-red-400"

  defp difficulty_class(_), do: "bg-elevated border border-border text-muted-foreground"
end
