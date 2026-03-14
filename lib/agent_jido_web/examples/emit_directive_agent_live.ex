defmodule AgentJidoWeb.Examples.EmitDirectiveAgentLive do
  @moduledoc """
  Interactive demo for emit directives using a real AgentServer runtime.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.EmitDirectiveAgent
  alias Jido.AgentServer
  alias Jido.Signal

  @poll_interval_ms 250

  @impl true
  def mount(_params, _session, socket) do
    fallback_agent = EmitDirectiveAgent.new(id: "emit-directive-preview")

    socket =
      socket
      |> assign(:server_pid, nil)
      |> assign(:agent, fallback_agent)
      |> assign(:order_total, 1500)
      |> assign(:multi_count, 3)
      |> assign(:log_entries, [])
      |> assign(:emitted_signals, [])
      |> assign(:last_error, nil)

    socket =
      if connected?(socket) do
        case start_demo_server(self()) do
          {:ok, pid, agent} ->
            Process.send_after(self(), :poll_state, @poll_interval_ms)

            socket
            |> assign(:server_pid, pid)
            |> assign(:agent, agent)

          {:error, reason} ->
            assign(socket, :last_error, "Failed to start runtime: #{inspect(reason)}")
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
    <div id="emit-directive-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="text-sm font-semibold text-foreground">Emit Directive Agent</div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          id: {@agent.id |> String.slice(0..7)}…
        </div>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 px-3 py-2 text-xs text-red-300">
        {@last_error}
      </div>

      <div class="grid sm:grid-cols-4 gap-3">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Orders</div>
          <div id="emit-orders-count" class="text-lg font-bold text-foreground mt-1">{length(@agent.state.orders)}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Last Order</div>
          <div id="emit-last-order-id" class="text-sm font-semibold text-foreground mt-2">
            {if @agent.state.last_order_id == "", do: "—", else: @agent.state.last_order_id}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Action Emits</div>
          <div class="text-lg font-bold text-foreground mt-1">{@agent.state.emitted_count}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Captured Signals</div>
          <div id="emit-signals-count" class="text-lg font-bold text-foreground mt-1">{length(@emitted_signals)}</div>
        </div>
      </div>

      <div class="grid gap-3 md:grid-cols-3">
        <form id="emit-create-order-form" phx-submit="create_order" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">call: create_order</div>
          <input type="number" name="total" value={@order_total} min="1" class="w-full px-2 py-1 text-sm rounded-md bg-background border border-border" />
          <button type="submit" class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary text-xs font-semibold">
            Create Order
          </button>
        </form>

        <button
          id="emit-process-payment-btn"
          phx-click="process_payment"
          class="rounded-md border border-border bg-elevated p-3 text-left hover:border-primary/40 transition-colors"
        >
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">call: process_payment</div>
          <div class="text-xs text-foreground mt-2">Uses latest order id in state.</div>
        </button>

        <form id="emit-multi-form" phx-submit="multi_emit" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">call: multi_emit</div>
          <input
            type="number"
            name="count"
            value={@multi_count}
            min="1"
            max="20"
            class="w-full px-2 py-1 text-sm rounded-md bg-background border border-border"
          />
          <button type="submit" class="px-3 py-1 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-400 text-xs font-semibold">
            Emit Batch
          </button>
        </form>
      </div>

      <div class="border-t border-border pt-4">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Execution Log</div>
        <div :if={@log_entries == []} class="text-xs text-muted-foreground">Run actions to inspect emitted events.</div>
        <div :if={@log_entries != []} class="space-y-1 max-h-56 overflow-y-auto">
          <%= for entry <- @log_entries do %>
            <div class="rounded-md border border-border bg-elevated/60 px-3 py-2 text-xs">
              <span class="font-semibold text-foreground">{entry.action}</span>
              <span class="text-muted-foreground ml-2">{entry.detail}</span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("create_order", %{"total" => total_raw}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, total} <- parse_positive_integer(total_raw) do
      order_id = "ORD-#{System.unique_integer([:positive])}"
      before = socket.assigns.agent

      case AgentServer.call(pid, Signal.new!("create_order", %{order_id: order_id, total: total}, source: "/demo")) do
        {:ok, agent} ->
          {:noreply,
           socket
           |> assign(:agent, agent)
           |> assign(:order_total, total)
           |> assign(:last_error, nil)
           |> append_log("create_order", "#{before.state.last_order_id} -> #{order_id}")}

        {:error, reason} ->
          {:noreply, assign(socket, :last_error, inspect(reason))}
      end
    else
      {:error, reason} ->
        {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  def handle_event("process_payment", _params, socket) do
    order_id = socket.assigns.agent.state.last_order_id

    if order_id in [nil, ""] do
      {:noreply, assign(socket, :last_error, "Create an order first.")}
    else
      case fetch_server_pid(socket) do
        {:ok, pid} ->
          case AgentServer.call(pid, Signal.new!("process_payment", %{order_id: order_id}, source: "/demo")) do
            {:ok, agent} ->
              {:noreply,
               socket
               |> assign(:agent, agent)
               |> assign(:last_error, nil)
               |> append_log("process_payment", order_id)}

            {:error, reason} ->
              {:noreply, assign(socket, :last_error, inspect(reason))}
          end

        {:error, reason} ->
          {:noreply, assign(socket, :last_error, inspect(reason))}
      end
    end
  end

  def handle_event("multi_emit", %{"count" => count_raw}, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, count} <- parse_positive_integer(count_raw) do
      case AgentServer.call(pid, Signal.new!("multi_emit", %{event_count: count}, source: "/demo")) do
        {:ok, agent} ->
          {:noreply,
           socket
           |> assign(:agent, agent)
           |> assign(:multi_count, count)
           |> assign(:last_error, nil)
           |> append_log("multi_emit", "count=#{count}")}

        {:error, reason} ->
          {:noreply, assign(socket, :last_error, inspect(reason))}
      end
    else
      {:error, reason} ->
        {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  @impl true
  def handle_info({:signal, %Signal{} = signal}, socket) do
    {:noreply, capture_emitted_signal(socket, signal)}
  end

  def handle_info({:signal, signal}, socket) when is_map(signal) do
    {:noreply, capture_emitted_signal(socket, struct(Signal, signal))}
  end

  def handle_info(%Signal{} = signal, socket) do
    {:noreply, capture_emitted_signal(socket, signal)}
  end

  def handle_info(:poll_state, socket) do
    socket = refresh_state(socket)
    Process.send_after(self(), :poll_state, @poll_interval_ms)
    {:noreply, socket}
  end

  defp start_demo_server(owner_pid) do
    id = "emit-directive-demo-#{System.unique_integer([:positive])}"

    with {:ok, pid} <-
           AgentServer.start_link(
             jido: AgentJido.Jido,
             agent: EmitDirectiveAgent,
             id: id,
             default_dispatch: {:pid, target: owner_pid}
           ),
         {:ok, %{agent: agent}} <- AgentServer.state(pid) do
      {:ok, pid, agent}
    end
  end

  defp refresh_state(socket) do
    case fetch_server_pid(socket) do
      {:ok, pid} ->
        case AgentServer.state(pid) do
          {:ok, %{agent: agent}} -> assign(socket, :agent, agent)
          _ -> socket
        end

      _ ->
        socket
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

  defp parse_positive_integer(raw) do
    case Integer.parse(to_string(raw)) do
      {value, ""} when value >= 1 -> {:ok, value}
      _other -> {:error, :invalid_integer}
    end
  end

  defp append_log(socket, action, detail) do
    entry = %{action: action, detail: detail, at: DateTime.utc_now()}
    assign(socket, :log_entries, [entry | socket.assigns.log_entries] |> Enum.take(40))
  end

  defp capture_emitted_signal(socket, signal) do
    entries = [signal | socket.assigns.emitted_signals] |> Enum.take(40)
    assign(socket, :emitted_signals, entries)
  end
end
