defmodule AgentJidoWeb.Examples.WeatherReasoningStrategySuiteLive do
  @moduledoc """
  Interactive comparison lab for weather reasoning strategies.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.WeatherReasoningStrategySuite.ComparisonLab

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :lab, ComparisonLab.new())}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:preset, assigns.lab.selected_preset)
      |> assign(:strategy, assigns.lab.selected_strategy)

    ~H"""
    <div id="weather-reasoning-strategy-suite-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Weather Reasoning Strategy Suite</div>
          <div class="text-[11px] text-muted-foreground">
            Deterministic comparison lab for choosing a strategy, not a single copy-pasteable weather agent
          </div>
        </div>
        <div class="text-[10px] font-semibold uppercase tracking-wider rounded border border-amber-400/30 bg-amber-400/10 text-amber-300 px-2 py-1">
          reference
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4 text-xs text-muted-foreground space-y-1">
        <div>No live model provider, browser session, or weather API call runs in this tab.</div>
        <div>The harness compares deterministic strategy profiles so you can choose the right implementation path before building a focused agent.</div>
      </div>

      <div class="space-y-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Scenario presets</div>
        <div class="flex gap-2 flex-wrap">
          <%= for preset <- ComparisonLab.presets() do %>
            <button
              phx-click="select_preset"
              phx-value-preset={preset.id}
              class={"px-3 py-2 rounded-md border text-xs transition-colors #{preset_button_class(@lab.selected_preset_id == preset.id)}"}
            >
              {preset.title}
            </button>
          <% end %>
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4 space-y-2">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Active scenario</div>
        <div id="weather-reasoning-selected-preset" class="text-sm font-semibold text-foreground">
          {@preset.title}
        </div>
        <div id="weather-reasoning-question" class="text-[11px] text-foreground whitespace-pre-wrap">
          {@preset.question}
        </div>
        <div class="text-[11px] text-muted-foreground">
          {@preset.summary}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-3">
        <div class="rounded-md border border-border bg-elevated p-3">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Recommended</div>
          <div id="weather-reasoning-recommended-strategy" class="text-sm font-semibold text-foreground mt-2">
            {@preset.recommendation.label}
          </div>
          <div class="text-[11px] text-muted-foreground mt-2">{@preset.recommendation.reason}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Fastest path</div>
          <div class="text-sm font-semibold text-foreground mt-2">{@preset.fastest.label}</div>
          <div class="text-[11px] text-muted-foreground mt-2">{@preset.fastest.reason}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Exploratory path</div>
          <div class="text-sm font-semibold text-foreground mt-2">{@preset.exploratory.label}</div>
          <div class="text-[11px] text-muted-foreground mt-2">{@preset.exploratory.reason}</div>
        </div>
      </div>

      <div class="space-y-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Strategy cards</div>
        <div id="weather-reasoning-comparison-grid" class="grid gap-3 lg:grid-cols-2">
          <%= for strategy <- @preset.strategies do %>
            <button
              id={"weather-reasoning-strategy-#{strategy.id}"}
              phx-click="select_strategy"
              phx-value-strategy={strategy.id}
              class={"rounded-md border p-4 text-left transition-colors #{strategy_card_class(@lab.selected_strategy_id == strategy.id)}"}
            >
              <div class="flex items-start justify-between gap-3">
                <div>
                  <div class="text-sm font-semibold text-foreground">{strategy.name}</div>
                  <div class="text-[11px] text-muted-foreground mt-1">{strategy.style}</div>
                </div>
                <div class={"text-[10px] uppercase tracking-wider rounded px-2 py-1 #{fit_class(strategy.fit)}"}>
                  {strategy.fit}
                </div>
              </div>

              <div class="grid gap-2 sm:grid-cols-2 mt-4 text-[11px]">
                <div>
                  <div class="uppercase tracking-wider text-muted-foreground">Latency</div>
                  <div class="text-foreground mt-1">{strategy.latency}</div>
                </div>
                <div>
                  <div class="uppercase tracking-wider text-muted-foreground">Output</div>
                  <div class="text-foreground mt-1">{strategy.output_shape}</div>
                </div>
              </div>

              <div class="text-[11px] text-muted-foreground mt-3">{strategy.why}</div>
            </button>
          <% end %>
        </div>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1fr_0.9fr]">
        <div class="rounded-md border border-border bg-elevated p-4 space-y-4">
          <div>
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Selected strategy</div>
            <div id="weather-reasoning-selected-strategy" class="text-sm font-semibold text-foreground mt-2">
              {@strategy.name}
            </div>
            <div class="text-[11px] text-muted-foreground mt-2">{@strategy.style}</div>
          </div>

          <div class="grid gap-3 sm:grid-cols-2">
            <div class="rounded-md border border-border bg-background/70 p-3">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Best for</div>
              <div class="text-[11px] text-foreground mt-2">{@strategy.best_for}</div>
            </div>
            <div class="rounded-md border border-border bg-background/70 p-3">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Tradeoff</div>
              <div class="text-[11px] text-foreground mt-2">{@strategy.tradeoff}</div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-background/70 p-3">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Why this fit changes on this prompt</div>
            <div class="text-[11px] text-foreground mt-2">{@strategy.why}</div>
          </div>

          <div class="rounded-md border border-border bg-background/70 p-3">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Reference snippet</div>
            <div id="weather-reasoning-reference-snippet" class="text-[11px] text-foreground whitespace-pre-wrap mt-2">
              {@strategy.sample}
            </div>
          </div>
        </div>

        <div class="rounded-md border border-border bg-elevated p-4">
          <div class="flex items-center justify-between mb-2">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Activity</div>
            <div class="text-[10px] text-muted-foreground">{length(@lab.log)} note(s)</div>
          </div>

          <div id="weather-reasoning-log" class="space-y-2 max-h-[26rem] overflow-y-auto">
            <%= for entry <- @lab.log do %>
              <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
                <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select_preset", %{"preset" => preset_id}, socket) do
    {:noreply, assign(socket, :lab, ComparisonLab.select_preset(socket.assigns.lab, preset_id))}
  end

  def handle_event("select_strategy", %{"strategy" => strategy_id}, socket) do
    {:noreply, assign(socket, :lab, ComparisonLab.select_strategy(socket.assigns.lab, strategy_id))}
  end

  defp preset_button_class(true) do
    "bg-primary/10 border-primary/30 text-primary"
  end

  defp preset_button_class(false) do
    "bg-background border-border text-muted-foreground hover:text-foreground hover:border-primary/30"
  end

  defp strategy_card_class(true) do
    "border-primary/40 bg-primary/10 shadow-sm"
  end

  defp strategy_card_class(false) do
    "border-border bg-background/70 hover:border-primary/20"
  end

  defp fit_class("Best fit"), do: "bg-emerald-500/10 text-emerald-300 border border-emerald-500/30"
  defp fit_class("Strong"), do: "bg-primary/10 text-primary border border-primary/30"
  defp fit_class("Situational"), do: "bg-amber-400/10 text-amber-300 border border-amber-400/30"
  defp fit_class("Overkill"), do: "bg-rose-400/10 text-rose-300 border border-rose-400/30"
  defp fit_class(_other), do: "bg-elevated text-muted-foreground border border-border"
end
