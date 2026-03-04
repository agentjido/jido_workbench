defmodule AgentJidoWeb.Examples.PluginBasicsAgentLive do
  @moduledoc """
  Interactive demo for plugin-based state and routes.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.PluginBasicsAgent
  alias Jido.AgentServer
  alias Jido.Signal

  @poll_interval_ms 250

  @impl true
  def mount(_params, _session, socket) do
    fallback_agent = PluginBasicsAgent.new(id: "plugin-basics-preview")

    socket =
      socket
      |> assign(:server_pid, nil)
      |> assign(:agent, fallback_agent)
      |> assign(:note_text, "hello plugin")
      |> assign(:log_entries, [])
      |> assign(:last_error, nil)

    socket =
      if connected?(socket) do
        case start_demo_server() do
          {:ok, pid, agent} ->
            Process.send_after(self(), :poll_state, @poll_interval_ms)
            socket |> assign(:server_pid, pid) |> assign(:agent, agent)

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
    <div id="plugin-basics-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div class="text-sm font-semibold text-foreground">Plugin Basics Agent</div>
        <div class="text-[10px] text-muted-foreground font-mono bg-elevated px-2 py-0.5 rounded border border-border">
          label: {@agent.state.notes.label}
        </div>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 px-3 py-2 text-xs text-red-300">
        {@last_error}
      </div>

      <div class="grid sm:grid-cols-2 gap-3">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Entries</div>
          <div id="plugin-notes-count" class="text-lg font-bold text-foreground mt-1">{length(@agent.state.notes.entries)}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Plugin Label</div>
          <div id="plugin-notes-label" class="text-sm font-semibold text-foreground mt-2">{@agent.state.notes.label}</div>
        </div>
      </div>

      <form id="plugin-add-note-form" phx-submit="add_note" class="rounded-md border border-border bg-elevated p-3 space-y-2">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">signal: notes.add</div>
        <div class="flex gap-2">
          <input type="text" name="text" value={@note_text} required class="flex-1 px-2 py-1 text-sm rounded-md bg-background border border-border" />
          <button type="submit" class="px-3 py-1 rounded-md bg-primary/10 border border-primary/30 text-primary text-xs font-semibold">Add</button>
        </div>
      </form>

      <button
        id="plugin-clear-notes-btn"
        phx-click="clear_notes"
        class="px-3 py-2 rounded-md bg-elevated border border-border text-xs hover:border-primary/40"
      >
        signal: notes.clear
      </button>

      <div class="rounded-md border border-border bg-elevated p-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Entries</div>
        <div :if={@agent.state.notes.entries == []} class="text-xs text-muted-foreground">No notes yet.</div>
        <div :if={@agent.state.notes.entries != []} class="space-y-1 max-h-48 overflow-y-auto">
          <%= for note <- @agent.state.notes.entries do %>
            <div class="text-xs rounded bg-background border border-border px-2 py-1">{note.text}</div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add_note", %{"text" => text}, socket) do
    trimmed = String.trim(text)

    with {:ok, pid} <- fetch_server_pid(socket),
         true <- trimmed != "",
         {:ok, agent} <- AgentServer.call(pid, Signal.new!("notes.add", %{text: trimmed}, source: "/demo")) do
      entry = %{action: "notes.add", detail: trimmed, at: DateTime.utc_now()}

      {:noreply,
       socket
       |> assign(:agent, agent)
       |> assign(:note_text, trimmed)
       |> assign(:last_error, nil)
       |> assign(:log_entries, [entry | socket.assigns.log_entries] |> Enum.take(30))}
    else
      false -> {:noreply, assign(socket, :last_error, "Text is required.")}
      {:error, reason} -> {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  def handle_event("clear_notes", _params, socket) do
    with {:ok, pid} <- fetch_server_pid(socket),
         {:ok, agent} <- AgentServer.call(pid, Signal.new!("notes.clear", %{}, source: "/demo")) do
      entry = %{action: "notes.clear", detail: "all entries removed", at: DateTime.utc_now()}

      {:noreply,
       socket
       |> assign(:agent, agent)
       |> assign(:last_error, nil)
       |> assign(:log_entries, [entry | socket.assigns.log_entries] |> Enum.take(30))}
    else
      {:error, reason} -> {:noreply, assign(socket, :last_error, inspect(reason))}
    end
  end

  @impl true
  def handle_info(:poll_state, socket) do
    socket =
      case fetch_server_pid(socket) do
        {:ok, pid} ->
          case AgentServer.state(pid) do
            {:ok, %{agent: agent}} -> assign(socket, :agent, agent)
            _ -> socket
          end

        _ ->
          socket
      end

    Process.send_after(self(), :poll_state, @poll_interval_ms)
    {:noreply, socket}
  end

  defp start_demo_server do
    id = "plugin-basics-demo-#{System.unique_integer([:positive])}"

    with {:ok, pid} <- AgentServer.start_link(jido: AgentJido.Jido, agent: PluginBasicsAgent, id: id),
         {:ok, %{agent: agent}} <- AgentServer.state(pid) do
      {:ok, pid, agent}
    end
  end

  defp fetch_server_pid(socket) do
    case socket.assigns.server_pid do
      pid when is_pid(pid) -> if(Process.alive?(pid), do: {:ok, pid}, else: {:error, :runtime_not_started})
      _ -> {:error, :runtime_not_started}
    end
  end
end
