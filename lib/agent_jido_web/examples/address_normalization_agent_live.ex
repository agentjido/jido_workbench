defmodule AgentJidoWeb.Examples.AddressNormalizationAgentLive do
  @moduledoc """
  Interactive demo for address normalization.

  The demo is deterministic: it runs one valid payload and one invalid payload
  to make action-contract validation behavior explicit.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.AddressNormalization.{ExecuteAction, ResetAction}
  alias AgentJido.Demos.AddressNormalizationAgent
  alias Jido.Agent.Directive

  @valid_payload %{
    line1: " 123   main st ",
    city: "san francisco",
    region: "california",
    postal_code: "94105-1234",
    country: "us"
  }

  # Intentionally missing :postal_code to show contract validation.
  @invalid_payload %{
    line1: "500 market st",
    city: "san francisco",
    region: "ca",
    country: "us"
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:agent, AddressNormalizationAgent.new())
     |> assign(:history, [])
     |> assign(:last_error, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="address-normalization-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
          <div class="text-sm font-semibold text-foreground">Address Normalization Agent</div>
        </div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          id: {@agent.id |> String.slice(0..7)}…
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4 space-y-2">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
          Action Contract
        </div>
        <div class="text-xs font-mono text-foreground">
          required fields: line1, city, region, postal_code, country
        </div>
        <div class="text-xs text-muted-foreground">
          postal codes are normalized to 5 digits, country must normalize to US.
        </div>
      </div>

      <div class="flex items-center gap-3 flex-wrap">
        <button
          phx-click="run_valid_sample"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run Valid Payload
        </button>
        <button
          phx-click="run_invalid_sample"
          class="px-4 py-2 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-400 hover:bg-amber-500/20 transition-colors text-sm font-semibold"
        >
          Run Invalid Payload
        </button>
        <button
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 p-3">
        <div class="text-xs font-semibold text-red-300">{@last_error.summary}</div>
        <div class="text-xs text-red-200/80 mt-1">{@last_error.detail}</div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4 space-y-2">
        <div class="flex items-center justify-between">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
            Normalized Output
          </div>
          <div class="text-[10px] text-muted-foreground font-mono">
            successful runs: {@agent.state.successful_runs}
          </div>
        </div>
        <div class="text-sm text-foreground font-mono">
          {if @agent.state.normalized_address == "", do: "No normalized address yet", else: @agent.state.normalized_address}
        </div>
      </div>

      <div :if={@history != []} class="border-t border-border pt-4">
        <div class="flex items-center justify-between mb-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Run History</div>
          <div class="text-[10px] text-muted-foreground">{length(@history)} events</div>
        </div>
        <div class="space-y-1 max-h-52 overflow-y-auto">
          <%= for entry <- Enum.take(@history, 20) do %>
            <div class="flex items-start gap-2 text-xs font-mono py-1 px-2 rounded bg-elevated/50">
              <span class={history_kind_class(entry.kind)}>{entry.kind}</span>
              <span class="text-muted-foreground">{entry.label}</span>
              <span class="text-foreground truncate">{entry.detail}</span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("run_valid_sample", _params, socket) do
    {:noreply, execute_payload(socket, @valid_payload, "valid sample")}
  end

  def handle_event("run_invalid_sample", _params, socket) do
    {:noreply, execute_payload(socket, @invalid_payload, "invalid sample")}
  end

  def handle_event("reset_demo", _params, socket) do
    {new_agent, _directives} = AddressNormalizationAgent.cmd(socket.assigns.agent, ResetAction)

    entry = %{
      kind: "reset",
      label: "reset",
      detail: "agent state reset",
      at: DateTime.utc_now()
    }

    {:noreply,
     socket
     |> assign(:agent, new_agent)
     |> assign(:last_error, nil)
     |> assign(:history, [entry | socket.assigns.history])}
  end

  defp execute_payload(socket, payload, label) do
    {new_agent, directives} = AddressNormalizationAgent.cmd(socket.assigns.agent, {ExecuteAction, payload})

    case first_error_message(directives) do
      nil ->
        entry = %{
          kind: "ok",
          label: label,
          detail: new_agent.state.normalized_address,
          at: DateTime.utc_now()
        }

        socket
        |> assign(:agent, new_agent)
        |> assign(:last_error, nil)
        |> assign(:history, [entry | socket.assigns.history])

      error_message ->
        entry = %{
          kind: "error",
          label: label,
          detail: error_message,
          at: DateTime.utc_now()
        }

        socket
        |> assign(:agent, new_agent)
        |> assign(:last_error, %{
          summary: "Action contract rejected the payload.",
          detail: error_message
        })
        |> assign(:history, [entry | socket.assigns.history])
    end
  end

  defp first_error_message(directives) do
    Enum.find_value(directives, fn
      %Directive.Error{error: %{message: message}} -> message
      %Directive.Error{error: error} -> inspect(error)
      _ -> nil
    end)
  end

  defp history_kind_class("ok"),
    do: "text-emerald-400 bg-emerald-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"

  defp history_kind_class("error"),
    do: "text-red-400 bg-red-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"

  defp history_kind_class("reset"),
    do: "text-amber-400 bg-amber-400/10 px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"

  defp history_kind_class(_),
    do: "text-muted-foreground bg-elevated px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0"
end
