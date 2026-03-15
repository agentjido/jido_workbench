defmodule AgentJidoWeb.Examples.WeatherMultiTurnContextLive do
  @moduledoc """
  Interactive demo for deterministic multi-turn weather context carryover.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.WeatherMultiTurnContext.RuntimeDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :demo, RuntimeDemo.new())}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :assistant, assigns.demo.assistant)

    ~H"""
    <div id="weather-multi-turn-context-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Weather Multi-Turn Context</div>
          <div class="text-[11px] text-muted-foreground">
            Real local weather-tool calls with preserved city context and deterministic retry/backoff behavior
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          city: {@assistant.current_city || "unset"}
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-4">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Selected City</div>
          <div id="weather-selected-city" class="text-sm font-semibold text-foreground mt-2">
            {@assistant.selected_city.city}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Context City</div>
          <div id="weather-context-city" class="text-sm font-semibold text-foreground mt-2">
            {@assistant.current_city || "pending"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Turns Completed</div>
          <div id="weather-turn-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@assistant.turns)}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Retry Events</div>
          <div id="weather-retry-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@assistant.retry_events)}
          </div>
        </div>
      </div>

      <div class="space-y-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">City presets</div>
        <div class="flex gap-2 flex-wrap">
          <%= for city <- RuntimeDemo.cities() do %>
            <button
              phx-click="select_city"
              phx-value-city={city.id}
              class={"px-3 py-2 rounded-md border text-xs transition-colors #{city_button_class(@assistant.selected_city_id == city.id)}"}
            >
              {city.city}
            </button>
          <% end %>
        </div>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="weather-run-turn-1-btn"
          phx-click="run_turn"
          phx-value-turn="forecast"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run Turn 1
        </button>
        <button
          id="weather-run-turn-2-btn"
          phx-click="run_turn"
          phx-value-turn="umbrella"
          class="px-4 py-2 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/20 transition-colors text-sm font-semibold"
        >
          Run Turn 2
        </button>
        <button
          id="weather-run-turn-3-btn"
          phx-click="run_turn"
          phx-value-turn="activities"
          class="px-4 py-2 rounded-md bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan hover:bg-accent-cyan/20 transition-colors text-sm font-semibold"
        >
          Run Turn 3
        </button>
        <button
          id="weather-run-all-btn"
          phx-click="run_all"
          class="px-4 py-2 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-300 hover:bg-amber-500/20 transition-colors text-sm font-semibold"
        >
          Run Full Conversation
        </button>
        <button
          id="weather-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1.1fr_0.9fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Conversation Transcript</div>
              <div class="text-[10px] text-muted-foreground">{length(@assistant.turns)} turn(s)</div>
            </div>

            <div :if={@assistant.turns == []} class="text-xs text-muted-foreground">
              Run the first turn to anchor the city context, then follow up without repeating the location.
            </div>

            <div :if={@assistant.turns != []} id="weather-turns" class="space-y-3">
              <%= for turn <- @assistant.turns do %>
                <div class="rounded-md border border-border bg-background/70 p-3 space-y-3">
                  <div class="flex items-center justify-between gap-3">
                    <div class="text-xs font-semibold text-foreground">{turn.title}</div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
                      {turn.attempts} attempt(s)
                    </div>
                  </div>
                  <div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">Prompt</div>
                    <div class="text-[11px] text-foreground whitespace-pre-wrap">{turn.prompt}</div>
                  </div>
                  <div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">Response</div>
                    <div class="text-[11px] text-foreground whitespace-pre-wrap">{turn.response}</div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Retry and Backoff</div>
              <div class="text-[10px] text-muted-foreground">{length(@assistant.retry_events)} event(s)</div>
            </div>

            <div :if={@assistant.retry_events == []} class="text-xs text-muted-foreground">
              The umbrella follow-up triggers one deterministic busy response, then retries after a local backoff.
            </div>

            <div :if={@assistant.retry_events != []} id="weather-retry-log" class="space-y-2">
              <%= for retry <- @assistant.retry_events do %>
                <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                  <div class="text-[11px] font-semibold text-foreground">{retry.turn} retry</div>
                  <div class="text-[11px] text-muted-foreground">
                    {retry.city} returned busy on attempt {retry.attempt}; backed off {retry.backoff_ms}ms.
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Tool Calls</div>
              <div class="text-[10px] text-muted-foreground">{length(@assistant.tool_calls)} call(s)</div>
            </div>

            <div :if={@assistant.tool_calls == []} class="text-xs text-muted-foreground">
              Each turn records the underlying local weather-tool call and whether it succeeded or retried.
            </div>

            <div :if={@assistant.tool_calls != []} id="weather-tool-calls" class="space-y-2 max-h-[20rem] overflow-y-auto">
              <%= for call <- @assistant.tool_calls do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="flex items-center justify-between gap-3">
                    <div class="text-[11px] font-semibold text-foreground">{call.turn}</div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground">{call.status}</div>
                  </div>
                  <div class="text-[11px] text-muted-foreground mt-1">
                    {call.city} · attempt {call.attempt}
                  </div>
                  <pre class="text-[11px] text-foreground whitespace-pre-wrap font-mono mt-2"><%= inspect(call.payload, pretty: true, width: 60) %></pre>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Activity Log</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.log)} entry(s)</div>
            </div>

            <div :if={@demo.log == []} class="text-xs text-muted-foreground">
              Run the conversation to inspect context carryover and retry notes.
            </div>

            <div :if={@demo.log != []} class="space-y-2 max-h-[18rem] overflow-y-auto">
              <%= for entry <- @demo.log do %>
                <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                  <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
                  <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select_city", %{"city" => city_id}, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.select_city(socket.assigns.demo, city_id))}
  end

  def handle_event("run_turn", %{"turn" => turn}, socket) do
    turn_id = String.to_existing_atom(turn)
    {:noreply, assign(socket, :demo, RuntimeDemo.run_turn(socket.assigns.demo, turn_id))}
  end

  def handle_event("run_all", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.run_all(socket.assigns.demo))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign(socket, :demo, RuntimeDemo.reset(socket.assigns.demo))}
  end

  defp city_button_class(true), do: "border-primary/40 bg-primary/10 text-primary"
  defp city_button_class(false), do: "border-border bg-elevated text-muted-foreground hover:text-foreground hover:border-primary/30"
end
