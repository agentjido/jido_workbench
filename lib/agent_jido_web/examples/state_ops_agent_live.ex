defmodule AgentJidoWeb.Examples.StateOpsAgentLive do
  @moduledoc """
  Interactive demo for common `StateOp` patterns using pure `cmd/2`.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.StateOps.{
    ClearTempDataAction,
    DeleteNestedValueAction,
    MergeMetadataAction,
    ReplaceAllAction,
    SetNestedValueAction
  }

  alias AgentJido.Demos.StateOpsAgent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:agent, StateOpsAgent.new())
     |> assign(:log_entries, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="state-ops-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="text-sm font-semibold text-foreground">State Ops Agent</div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          id: {@agent.id |> String.slice(0..7)}…
        </div>
      </div>

      <div class="grid gap-2 sm:grid-cols-2 lg:grid-cols-5">
        <button id="state-merge-btn" phx-click="merge_metadata" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          SetState
        </button>
        <button id="state-replace-btn" phx-click="replace_all" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          ReplaceState
        </button>
        <button id="state-clear-btn" phx-click="clear_temp" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          DeleteKeys
        </button>
        <button id="state-set-path-btn" phx-click="set_nested" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          SetPath
        </button>
        <button id="state-del-path-btn" phx-click="delete_nested" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          DeletePath
        </button>
      </div>

      <div class="rounded-md border border-border bg-elevated p-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Current State</div>
        <pre id="state-ops-state" class="text-xs text-foreground font-mono whitespace-pre-wrap"><%= inspect(@agent.state, pretty: true, width: 80) %></pre>
      </div>

      <div class="border-t border-border pt-4">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Execution Log</div>
        <div :if={@log_entries == []} class="text-xs text-muted-foreground">Run operations to inspect state mutations.</div>
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
  def handle_event("merge_metadata", _params, socket) do
    dispatch(socket, "SetState", {MergeMetadataAction, %{metadata: %{version: "1.0", owner: "ops"}}})
  end

  def handle_event("replace_all", _params, socket) do
    new_state = %{counter: 0, name: "fresh", step: :reset, config: %{timeout: 2000}}
    dispatch(socket, "ReplaceState", {ReplaceAllAction, %{new_state: new_state}})
  end

  def handle_event("clear_temp", _params, socket) do
    dispatch(socket, "DeleteKeys", ClearTempDataAction)
  end

  def handle_event("set_nested", _params, socket) do
    dispatch(socket, "SetPath", {SetNestedValueAction, %{path: [:config, :timeout], value: 5000}})
  end

  def handle_event("delete_nested", _params, socket) do
    dispatch(socket, "DeletePath", {DeleteNestedValueAction, %{path: [:config, :secret]}})
  end

  defp dispatch(socket, label, action) do
    before = socket.assigns.agent
    {agent, _directives} = StateOpsAgent.cmd(before, action)

    entry = %{
      action: label,
      detail: "counter #{Map.get(before.state, :counter, 0)} -> #{Map.get(agent.state, :counter, 0)}",
      at: DateTime.utc_now()
    }

    {:noreply, assign(socket, :agent, agent) |> assign(:log_entries, [entry | socket.assigns.log_entries] |> Enum.take(40))}
  end
end
