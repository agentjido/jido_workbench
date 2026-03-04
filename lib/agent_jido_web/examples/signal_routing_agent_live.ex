defmodule AgentJidoWeb.Examples.SignalRoutingAgentLive do
  @moduledoc """
  Interactive demo for signal routing via a real `Jido.AgentServer` runtime.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.SignalRoutingAgent
  alias Jido.AgentServer
  alias Jido.Signal

  @poll_interval_ms 250
  @max_log_entries 40
  @signal_source "/examples/signal-routing-agent"

  @impl true
  def mount(_params, _session, socket) do
    fallback_agent = SignalRoutingAgent.new(id: "signal-routing-preview")

    socket =
      socket
      |> assign(:server_pid, nil)
      |> assign(:agent, fallback_agent)
      |> assign(:increment_amount, 1)
      |> assign(:name_input, "Router")
      |> assign(:event_type_input, "checkpoint")
      |> assign(:event_payload_input, ~s({"source":"demo","status":"ok"}))
      |> assign(:cast_count, 5)
      |> assign(:log_entries, [])
      |> assign(:last_error, nil)

    socket =
      if connected?(socket) do
        case start_demo_server() do
          {:ok, pid, agent} ->
            Process.send_after(self(), :poll_state, @poll_interval_ms)

            socket
            |> assign(:server_pid, pid)
            |> assign(:agent, agent)

          {:error, reason} ->
            put_error(socket, "Failed to start demo runtime.", inspect(reason))
        end
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    if pid = socket.assigns[:server_pid] do
      if Process.alive?(pid), do: GenServer.stop(pid, :normal)
    end

    :ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="signal-routing-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
          <div class="text-sm font-semibold text-foreground">Signal Routing Agent</div>
        </div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          id: {@agent.id |> String.slice(0..7)}…
        </div>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 px-4 py-3">
        <div class="text-xs font-semibold text-red-300">{@last_error.summary}</div>
        <div class="text-xs text-red-200/80 mt-1">{@last_error.detail}</div>
      </div>

      <div id="signal-routing-state" class="grid gap-3 sm:grid-cols-3">
        <div class="rounded-md bg-elevated border border-border p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Counter</div>
          <div id="signal-routing-counter" class="text-xl font-bold text-foreground tabular-nums mt-1">
            {@agent.state.counter}
          </div>
        </div>
        <div class="rounded-md bg-elevated border border-border p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Name</div>
          <div id="signal-routing-name" class="text-sm font-semibold text-foreground mt-2 truncate">
            {if @agent.state.name == "", do: "—", else: @agent.state.name}
          </div>
        </div>
        <div class="rounded-md bg-elevated border border-border p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Events</div>
          <div id="signal-routing-events-count" class="text-xl font-bold text-foreground tabular-nums mt-1">
            {length(@agent.state.events)}
          </div>
        </div>
      </div>

      <div class="grid gap-3 md:grid-cols-2">
        <form id="signal-routing-increment-form" phx-submit="call_increment" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
            call: increment
          </div>
          <div class="flex items-center gap-2">
            <input
              type="number"
              name="amount"
              value={@increment_amount}
              min="1"
              class="w-24 px-2 py-1 text-sm rounded-md bg-background border border-border text-foreground focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none"
            />
            <button
              type="submit"
              class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-xs font-semibold"
            >
              Send call
            </button>
          </div>
        </form>

        <form id="signal-routing-name-form" phx-submit="call_set_name" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
            call: set_name
          </div>
          <div class="flex items-center gap-2">
            <input
              type="text"
              name="name"
              value={@name_input}
              placeholder="Router"
              required
              class="flex-1 px-2 py-1 text-sm rounded-md bg-background border border-border text-foreground focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none"
            />
            <button
              type="submit"
              class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-xs font-semibold"
            >
              Send call
            </button>
          </div>
        </form>

        <form
          id="signal-routing-event-form"
          phx-submit="call_record_event"
          class="rounded-md border border-border bg-elevated p-3 space-y-2 md:col-span-2"
        >
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
            call: record_event (json payload)
          </div>
          <div class="grid gap-2 sm:grid-cols-3">
            <input
              type="text"
              name="event_type"
              value={@event_type_input}
              class="px-2 py-1 text-sm rounded-md bg-background border border-border text-foreground focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none"
            />
            <textarea
              name="payload_json"
              rows="2"
              class="sm:col-span-2 px-2 py-1 text-sm rounded-md bg-background border border-border text-foreground focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none font-mono"
            ><%= @event_payload_input %></textarea>
          </div>
          <button
            type="submit"
            class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-xs font-semibold"
          >
            Send call
          </button>
        </form>

        <form id="signal-routing-cast-form" phx-submit="cast_burst" class="rounded-md border border-border bg-elevated p-3 space-y-2 md:col-span-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
            cast burst: send 1..N increment signals
          </div>
          <div class="flex items-center gap-2">
            <input
              type="number"
              name="count"
              value={@cast_count}
              min="1"
              max="50"
              class="w-24 px-2 py-1 text-sm rounded-md bg-background border border-border text-foreground focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none"
            />
            <button
              type="submit"
              class="px-3 py-1 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-400 hover:bg-amber-500/20 transition-colors text-xs font-semibold"
            >
              Send cast burst
            </button>
          </div>
        </form>
      </div>

      <div class="border-t border-border pt-4">
        <div class="flex items-center justify-between mb-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Execution Log</div>
          <div class="text-[10px] text-muted-foreground">{length(@log_entries)} entries</div>
        </div>

        <div :if={@log_entries == []} class="text-xs text-muted-foreground">
          Send call or cast actions to inspect routing behavior.
        </div>

        <div :if={@log_entries != []} class="space-y-2 max-h-64 overflow-y-auto">
          <%= for entry <- @log_entries do %>
            <div class="rounded-md border border-border bg-elevated/60 px-3 py-2">
              <div class="flex gap-2 items-center flex-wrap">
                <span class={log_mode_class(entry.mode)}>{entry.mode}</span>
                <span class="text-xs font-semibold text-foreground">{entry.signal_type}</span>
                <span class="text-[11px] text-muted-foreground">{entry.payload}</span>
              </div>
              <div class="text-[11px] text-muted-foreground mt-1">
                counter {entry.from.counter} → {entry.to.counter}, name {format_name(entry.from.name)} → {format_name(entry.to.name)}, events {entry.from.events_count} → {entry.to.events_count}
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("call_increment", %{"amount" => amount_raw}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, amount} <- parse_positive_integer(amount_raw),
         {:ok, agent} <- send_call_signal(pid, "increment", %{amount: amount}) do
      {:noreply,
       socket
       |> assign(:increment_amount, amount)
       |> assign(:last_error, nil)
       |> assign(:agent, agent)
       |> append_log("call", "increment", %{amount: amount}, socket.assigns.agent, agent)}
    else
      {:error, reason} ->
        {:noreply, put_error(socket, "Unable to call increment.", inspect(reason))}
    end
  end

  def handle_event("call_set_name", %{"name" => raw_name}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         name <- String.trim(raw_name),
         true <- name != "",
         {:ok, agent} <- send_call_signal(pid, "set_name", %{name: name}) do
      {:noreply,
       socket
       |> assign(:name_input, name)
       |> assign(:last_error, nil)
       |> assign(:agent, agent)
       |> append_log("call", "set_name", %{name: name}, socket.assigns.agent, agent)}
    else
      false ->
        {:noreply, put_error(socket, "Name is required.", "Enter a name before sending call.")}

      {:error, reason} ->
        {:noreply, put_error(socket, "Unable to call set_name.", inspect(reason))}
    end
  end

  def handle_event(
        "call_record_event",
        %{"event_type" => raw_event_type, "payload_json" => payload_json},
        socket
      ) do
    with {:ok, pid} <- fetch_server_pid(socket),
         event_type <- String.trim(raw_event_type),
         true <- event_type != "",
         {:ok, payload} <- decode_payload(payload_json),
         {:ok, agent} <- send_call_signal(pid, "record_event", %{event_type: event_type, payload: payload}) do
      {:noreply,
       socket
       |> assign(:event_type_input, event_type)
       |> assign(:event_payload_input, payload_json)
       |> assign(:last_error, nil)
       |> assign(:agent, agent)
       |> append_log(
         "call",
         "record_event",
         %{event_type: event_type, payload: payload},
         socket.assigns.agent,
         agent
       )}
    else
      false ->
        {:noreply, put_error(socket, "Unable to call record_event.", "event_type cannot be blank.")}

      {:error, reason} ->
        {:noreply, put_error(socket, "Unable to call record_event.", inspect(reason))}
    end
  end

  def handle_event("cast_burst", %{"count" => count_raw}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, count} <- parse_positive_integer(count_raw),
         true <- count <= 50 do
      before_agent = socket.assigns.agent
      before_counter = before_agent.state.counter

      for _step <- 1..count do
        signal = Signal.new!("increment", %{amount: 1}, source: @signal_source)
        :ok = AgentServer.cast(pid, signal)
      end

      expected_counter = before_counter + count
      after_agent = wait_for_counter(pid, expected_counter, 25, before_agent)

      {:noreply,
       socket
       |> assign(:cast_count, count)
       |> assign(:last_error, nil)
       |> assign(:agent, after_agent)
       |> append_log("cast", "increment", %{count: count}, before_agent, after_agent)}
    else
      false ->
        {:noreply,
         put_error(
           socket,
           "Unable to send cast burst.",
           "Count must be between 1 and 50."
         )}

      {:error, reason} ->
        {:noreply, put_error(socket, "Unable to send cast burst.", inspect(reason))}
    end
  end

  @impl true
  def handle_info(:poll_state, socket) do
    socket = refresh_state(socket)
    Process.send_after(self(), :poll_state, @poll_interval_ms)
    {:noreply, socket}
  end

  defp start_demo_server do
    id = "signal-routing-demo-#{System.unique_integer([:positive])}"

    with {:ok, pid} <- AgentServer.start_link(jido: AgentJido.Jido, agent: SignalRoutingAgent, id: id),
         {:ok, %{agent: agent}} <- AgentServer.state(pid) do
      {:ok, pid, agent}
    end
  end

  defp send_call_signal(pid, signal_type, payload) do
    signal = Signal.new!(signal_type, payload, source: @signal_source)
    AgentServer.call(pid, signal)
  end

  defp refresh_state(socket) do
    case fetch_server_pid(socket) do
      {:ok, pid} ->
        case AgentServer.state(pid) do
          {:ok, %{agent: agent}} -> assign(socket, :agent, agent)
          {:error, _reason} -> socket
        end

      {:error, _reason} ->
        socket
    end
  end

  defp wait_for_counter(pid, target_counter, attempts_left, fallback_agent) do
    case AgentServer.state(pid) do
      {:ok, %{agent: agent}} when agent.state.counter >= target_counter ->
        agent

      {:ok, %{agent: agent}} ->
        if attempts_left > 0 do
          Process.sleep(25)
          wait_for_counter(pid, target_counter, attempts_left - 1, agent)
        else
          agent
        end

      {:error, _reason} ->
        fallback_agent
    end
  end

  defp decode_payload(json) do
    case Jason.decode(json) do
      {:ok, payload} when is_map(payload) ->
        {:ok, payload}

      {:ok, _other} ->
        {:error, "Payload JSON must decode to an object."}

      {:error, error} ->
        {:error, "Invalid JSON payload: #{Exception.message(error)}"}
    end
  end

  defp parse_positive_integer(raw) do
    case Integer.parse(to_string(raw)) do
      {int, ""} when int >= 1 -> {:ok, int}
      _other -> {:error, "Expected a positive integer."}
    end
  end

  defp fetch_server_pid(socket) do
    case socket.assigns.server_pid do
      pid when is_pid(pid) ->
        if Process.alive?(pid), do: {:ok, pid}, else: {:error, :runtime_not_started}

      _other ->
        {:error, :runtime_not_started}
    end
  end

  defp append_log(socket, mode, signal_type, payload, before_agent, after_agent) do
    entry = %{
      mode: mode,
      signal_type: signal_type,
      payload: inspect(payload),
      from: state_snapshot(before_agent),
      to: state_snapshot(after_agent),
      at: DateTime.utc_now()
    }

    logs = [entry | socket.assigns.log_entries] |> Enum.take(@max_log_entries)
    assign(socket, :log_entries, logs)
  end

  defp state_snapshot(agent) do
    %{
      counter: Map.get(agent.state, :counter, 0),
      name: Map.get(agent.state, :name, ""),
      events_count: Map.get(agent.state, :events, []) |> List.wrap() |> length()
    }
  end

  defp put_error(socket, summary, detail) do
    assign(socket, :last_error, %{summary: summary, detail: detail})
  end

  defp format_name(""), do: "—"
  defp format_name(name), do: name

  defp log_mode_class("call"),
    do: "text-emerald-400 bg-emerald-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase"

  defp log_mode_class("cast"),
    do: "text-amber-400 bg-amber-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase"

  defp log_mode_class(_),
    do: "text-muted-foreground bg-elevated px-1.5 py-0.5 rounded text-[10px] uppercase"
end
