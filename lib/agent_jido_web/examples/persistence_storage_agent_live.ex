defmodule AgentJidoWeb.Examples.PersistenceStorageAgentLive do
  @moduledoc """
  Interactive demo for persistence `hibernate` and `thaw` using ETS storage.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.PersistenceStorage.{AddNoteAction, IncrementAction}
  alias AgentJido.Demos.PersistenceStorageAgent
  alias Jido.Persist
  alias Jido.Storage.ETS

  @impl true
  def mount(_params, _session, socket) do
    table = String.to_atom("persist_demo_#{System.unique_integer([:positive])}")
    agent = PersistenceStorageAgent.new(id: "persist-demo-#{System.unique_integer([:positive])}")

    {:ok,
     socket
     |> assign(:agent, agent)
     |> assign(:storage_table, table)
     |> assign(:note_input, "checkpoint")
     |> assign(:log_entries, [])
     |> assign(:last_error, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="persistence-storage-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="text-sm font-semibold text-foreground">Persistence Storage Agent</div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          table: {@storage_table}
        </div>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 px-3 py-2 text-xs text-red-300">
        {@last_error}
      </div>

      <div class="grid sm:grid-cols-3 gap-3">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Counter</div>
          <div id="persist-counter" class="text-xl font-bold text-foreground mt-1">{@agent.state.counter}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Status</div>
          <div id="persist-status" class="text-sm font-semibold text-foreground mt-2">{@agent.state.status}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Notes</div>
          <div id="persist-notes-count" class="text-xl font-bold text-foreground mt-1">{length(@agent.state.notes)}</div>
        </div>
      </div>

      <div class="grid gap-3 md:grid-cols-2">
        <button id="persist-inc-btn" phx-click="increment" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          cmd: increment (+1)
        </button>

        <form id="persist-note-form" phx-submit="add_note" class="rounded-md border border-border bg-elevated p-3 space-y-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">cmd: add_note</div>
          <div class="flex gap-2">
            <input type="text" name="note" value={@note_input} required class="flex-1 px-2 py-1 text-sm rounded-md bg-background border border-border" />
            <button type="submit" class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary text-xs font-semibold">Add</button>
          </div>
        </form>

        <button id="persist-hibernate-btn" phx-click="hibernate" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          Persist.hibernate (save checkpoint)
        </button>

        <button id="persist-thaw-btn" phx-click="thaw" class="rounded-md border border-border bg-elevated p-3 text-xs hover:border-primary/40">
          Persist.thaw (restore checkpoint)
        </button>
      </div>

      <div class="rounded-md border border-border bg-elevated p-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">State</div>
        <pre class="text-xs text-foreground font-mono whitespace-pre-wrap"><%= inspect(@agent.state, pretty: true, width: 80) %></pre>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {agent, _directives} = PersistenceStorageAgent.cmd(socket.assigns.agent, {IncrementAction, %{amount: 1}})
    {:noreply, socket |> assign(:agent, agent) |> append_log("increment")}
  end

  def handle_event("add_note", %{"note" => note}, socket) do
    trimmed = String.trim(note)

    if trimmed == "" do
      {:noreply, assign(socket, :last_error, "Note is required.")}
    else
      {agent, _directives} =
        PersistenceStorageAgent.cmd(socket.assigns.agent, {AddNoteAction, %{note: trimmed}})

      {:noreply,
       socket
       |> assign(:agent, agent)
       |> assign(:note_input, trimmed)
       |> assign(:last_error, nil)
       |> append_log("add_note")}
    end
  end

  def handle_event("hibernate", _params, socket) do
    storage = {ETS, table: socket.assigns.storage_table}

    case Persist.hibernate(storage, socket.assigns.agent) do
      :ok -> {:noreply, socket |> assign(:last_error, nil) |> append_log("hibernate")}
      {:error, reason} -> {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  def handle_event("thaw", _params, socket) do
    storage = {ETS, table: socket.assigns.storage_table}
    id = socket.assigns.agent.id

    case Persist.thaw(storage, PersistenceStorageAgent, id) do
      {:ok, agent} ->
        {:noreply, socket |> assign(:agent, agent) |> assign(:last_error, nil) |> append_log("thaw")}

      {:error, reason} ->
        {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  defp append_log(socket, action) do
    entry = %{action: action, at: DateTime.utc_now()}
    assign(socket, :log_entries, [entry | socket.assigns.log_entries] |> Enum.take(40))
  end
end
