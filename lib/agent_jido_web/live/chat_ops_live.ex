defmodule AgentJidoWeb.ChatOpsLive do
  @moduledoc """
  Admin ChatOps console shell.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.ContentOps.Chat.{MessageTimeline, RoomInventory}

  @default_message_timeline_limit 50

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:inventory_provider, resolve_inventory_provider(session))
      |> assign(:message_provider, resolve_message_provider(session))
      |> assign(:message_timeline_limit, resolve_message_timeline_limit(session))
      |> assign(:room_inventory, [])
      |> assign(:inventory_error, nil)
      |> assign(:inventory_refreshed_at, nil)
      |> assign(:recent_messages, [])
      |> assign(:message_error, nil)
      |> assign(:message_refreshed_at, nil)
      |> refresh_inventory()
      |> refresh_recent_messages()

    {:ok, socket}
  end

  @impl true
  def handle_event("refresh_inventory", _params, socket) do
    {:noreply, refresh_inventory(socket)}
  end

  @impl true
  def handle_event("refresh_messages", _params, socket) do
    {:noreply, refresh_recent_messages(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto max-w-6xl space-y-8 px-6 py-12">
      <header class="space-y-2">
        <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">Admin Control Plane</p>
        <h1 class="text-3xl font-semibold text-foreground">ChatOps Console</h1>
        <p class="max-w-3xl text-sm text-muted-foreground">
          Operational shell for monitoring room state, chat activity, and execution safeguards.
        </p>
      </header>

      <section class="grid gap-4 lg:grid-cols-2">
        <article id="chatops-room-inventory-panel" class="space-y-4 rounded-lg border border-border bg-card p-6">
          <div class="flex items-start justify-between gap-4">
            <div class="space-y-1">
              <h2 class="text-lg font-semibold text-foreground">Room Inventory</h2>
              <p class="text-sm text-muted-foreground">
                Current room-to-channel bindings for Telegram and Discord.
              </p>
            </div>
            <div class="flex items-center gap-3">
              <span :if={@inventory_refreshed_at} class="text-[10px] font-mono text-muted-foreground">
                refreshed {format_refreshed_at(@inventory_refreshed_at)}
              </span>
              <button
                id="chatops-room-inventory-refresh"
                phx-click="refresh_inventory"
                class="text-xs text-muted-foreground transition-colors hover:text-foreground"
              >
                ↻ Refresh
              </button>
            </div>
          </div>

          <div :if={@inventory_error} id="chatops-room-inventory-error" class="text-xs font-mono text-red-400">
            ⚠ Unable to load room inventory: {@inventory_error}
          </div>

          <div
            :if={@room_inventory == []}
            id="chatops-room-inventory-empty"
            class="rounded-md border border-dashed border-border bg-elevated/40 p-4 text-sm text-muted-foreground"
          >
            No room bindings are currently available.
          </div>

          <div :if={@room_inventory != []} id="chatops-room-inventory-list" class="space-y-3">
            <div :for={room <- @room_inventory} class="space-y-3 rounded-md border border-border bg-elevated/50 p-4">
              <div class="flex items-start justify-between gap-3">
                <div class="space-y-1">
                  <h3 class="text-sm font-semibold text-foreground">{room.room_name}</h3>
                  <p class="text-xs font-mono text-muted-foreground">{room.room_id}</p>
                </div>
                <span class="text-[10px] uppercase tracking-wider text-muted-foreground">
                  {length(room.bindings)} binding(s)
                </span>
              </div>

              <div :if={room.bindings == []} class="text-xs text-muted-foreground">
                No channel bindings configured.
              </div>

              <ul :if={room.bindings != []} class="space-y-2">
                <li :for={binding <- room.bindings} class="flex flex-wrap items-center gap-2 text-xs">
                  <span class="rounded-full border border-border bg-card px-2 py-0.5 font-semibold text-foreground">
                    {binding_channel_label(binding.channel)}
                  </span>
                  <span class="font-mono text-foreground">{binding.external_room_id || "—"}</span>
                  <span class="text-muted-foreground">
                    instance: <span class="font-mono text-foreground">{binding.instance_id || "—"}</span>
                  </span>
                </li>
              </ul>
            </div>
          </div>
        </article>

        <article id="chatops-message-timeline-panel" class="space-y-4 rounded-lg border border-border bg-card p-6">
          <div class="flex items-start justify-between gap-4">
            <div class="space-y-1">
              <h2 class="text-lg font-semibold text-foreground">Recent Messages</h2>
              <p class="text-sm text-muted-foreground">
                Recent chat activity across bound room channels.
              </p>
              <p class="text-[10px] font-mono uppercase tracking-wider text-muted-foreground">
                showing latest {@message_timeline_limit} messages
              </p>
            </div>
            <div class="flex items-center gap-3">
              <span :if={@message_refreshed_at} class="text-[10px] font-mono text-muted-foreground">
                refreshed {format_refreshed_at(@message_refreshed_at)}
              </span>
              <button
                id="chatops-message-timeline-refresh"
                phx-click="refresh_messages"
                class="text-xs text-muted-foreground transition-colors hover:text-foreground"
              >
                ↻ Refresh
              </button>
            </div>
          </div>

          <div :if={@message_error} id="chatops-message-timeline-error" class="text-xs font-mono text-red-400">
            ⚠ Unable to load recent messages: {@message_error}
          </div>

          <div
            :if={@recent_messages == []}
            id="chatops-message-timeline-empty"
            class="rounded-md border border-dashed border-border bg-elevated/40 p-4 text-sm text-muted-foreground"
          >
            No recent messages are available.
          </div>

          <ol :if={@recent_messages != []} id="chatops-message-timeline-list" class="space-y-3">
            <li
              :for={{message, index} <- Enum.with_index(@recent_messages)}
              id={"chatops-message-row-#{index}"}
              class="space-y-2 rounded-md border border-border bg-elevated/50 p-4"
            >
              <div class="flex items-start justify-between gap-3">
                <span class="text-[10px] font-mono uppercase tracking-wider text-muted-foreground">
                  {format_message_timestamp(message)}
                </span>
                <span class="rounded-full border border-border bg-card px-2 py-0.5 text-[10px] font-semibold text-foreground">
                  {message_channel_label(message)}
                </span>
              </div>

              <div class="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-muted-foreground">
                <p>
                  room: <span class="font-mono text-foreground">{message_room_id(message)}</span>
                </p>
                <p>
                  actor: <span class="font-mono text-foreground">{message_actor(message)}</span>
                </p>
              </div>

              <p class="text-sm leading-relaxed text-foreground">{message_snippet(message)}</p>
            </li>
          </ol>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Action/Run Timeline</h2>
          <p class="text-sm text-muted-foreground">
            Placeholder for action and run events emitted by ChatOps workflows.
          </p>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Guardrails</h2>
          <p class="text-sm text-muted-foreground">
            Placeholder for authorization and mutation safety indicators.
          </p>
        </article>
      </section>
    </div>
    """
  end

  defp refresh_inventory(socket) do
    with {:ok, room_inventory} <- fetch_inventory(socket.assigns.inventory_provider) do
      socket
      |> assign(:room_inventory, room_inventory)
      |> assign(:inventory_error, nil)
      |> assign(:inventory_refreshed_at, DateTime.utc_now())
    else
      {:error, reason} ->
        socket
        |> assign(:room_inventory, [])
        |> assign(:inventory_error, format_error(reason))
        |> assign(:inventory_refreshed_at, DateTime.utc_now())
    end
  end

  defp refresh_recent_messages(socket) do
    limit = socket.assigns.message_timeline_limit

    with {:ok, recent_messages} <- fetch_recent_messages(socket.assigns.message_provider, limit: limit) do
      socket
      |> assign(:recent_messages, Enum.take(recent_messages, limit))
      |> assign(:message_error, nil)
      |> assign(:message_refreshed_at, DateTime.utc_now())
    else
      {:error, reason} ->
        socket
        |> assign(:recent_messages, [])
        |> assign(:message_error, format_error(reason))
        |> assign(:message_refreshed_at, DateTime.utc_now())
    end
  end

  defp fetch_inventory(provider) when is_atom(provider) do
    response =
      cond do
        function_exported?(provider, :fetch, 0) ->
          provider.fetch()

        function_exported?(provider, :fetch_room_inventory, 0) ->
          provider.fetch_room_inventory()

        true ->
          {:error, :invalid_inventory_provider}
      end

    case response do
      {:ok, inventory} when is_list(inventory) ->
        {:ok, normalize_inventory(inventory)}

      {:error, reason} ->
        {:error, reason}

      _other ->
        {:error, :invalid_inventory_response}
    end
  rescue
    error ->
      {:error, {:inventory_exception, Exception.message(error)}}
  catch
    :exit, reason ->
      {:error, {:inventory_exit, reason}}
  end

  defp fetch_inventory(_provider), do: {:error, :invalid_inventory_provider}

  defp fetch_recent_messages(provider, opts) when is_atom(provider) and is_list(opts) do
    response =
      cond do
        function_exported?(provider, :fetch_recent_messages, 1) ->
          provider.fetch_recent_messages(opts)

        function_exported?(provider, :fetch_recent_messages, 0) ->
          provider.fetch_recent_messages()

        function_exported?(provider, :fetch, 1) ->
          provider.fetch(opts)

        function_exported?(provider, :fetch, 0) ->
          provider.fetch()

        true ->
          {:error, :invalid_message_provider}
      end

    case response do
      {:ok, recent_messages} when is_list(recent_messages) ->
        {:ok, recent_messages}

      recent_messages when is_list(recent_messages) ->
        {:ok, recent_messages}

      {:error, reason} ->
        {:error, reason}

      _other ->
        {:error, :invalid_messages_response}
    end
  rescue
    error ->
      {:error, {:messaging_exception, Exception.message(error)}}
  catch
    :exit, reason ->
      {:error, {:messaging_exit, reason}}
  end

  defp fetch_recent_messages(_provider, _opts), do: {:error, :invalid_message_provider}

  defp normalize_inventory(inventory) do
    inventory
    |> Enum.map(&normalize_room/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.room_id)
  end

  defp normalize_room(room) when is_map(room) do
    room_id =
      Map.get(room, :room_id) ||
        Map.get(room, "room_id") ||
        Map.get(room, :id) ||
        Map.get(room, "id")

    if is_binary(room_id) and String.trim(room_id) != "" do
      %{
        room_id: room_id,
        room_name:
          normalize_string(
            Map.get(room, :room_name) ||
              Map.get(room, "room_name") ||
              Map.get(room, :name) ||
              Map.get(room, "name"),
            room_id
          ),
        bindings:
          room
          |> Map.get(:bindings, Map.get(room, "bindings", []))
          |> normalize_bindings()
      }
    else
      nil
    end
  end

  defp normalize_room(_room), do: nil

  defp normalize_bindings(bindings) when is_list(bindings) do
    bindings
    |> Enum.map(&normalize_binding/1)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_bindings(_bindings), do: []

  defp normalize_binding(binding) when is_map(binding) do
    %{
      channel:
        normalize_string(
          channel_to_string(Map.get(binding, :channel) || Map.get(binding, "channel")),
          "unknown"
        ),
      external_room_id:
        normalize_string(
          Map.get(binding, :external_room_id) || Map.get(binding, "external_room_id"),
          nil
        ),
      instance_id: normalize_string(Map.get(binding, :instance_id) || Map.get(binding, "instance_id"), nil)
    }
  end

  defp normalize_binding(_binding), do: nil

  defp channel_to_string(channel) when is_atom(channel), do: Atom.to_string(channel)
  defp channel_to_string(channel) when is_binary(channel), do: channel
  defp channel_to_string(nil), do: nil
  defp channel_to_string(channel), do: to_string(channel)

  defp normalize_string(nil, default), do: default

  defp normalize_string(value, default) when is_binary(value) do
    case String.trim(value) do
      "" -> default
      normalized -> normalized
    end
  end

  defp normalize_string(value, default), do: value |> to_string() |> normalize_string(default)

  defp binding_channel_label("telegram"), do: "Telegram"
  defp binding_channel_label("discord"), do: "Discord"

  defp binding_channel_label(channel) when is_binary(channel) do
    channel
    |> String.replace("_", " ")
    |> Phoenix.Naming.humanize()
  end

  defp binding_channel_label(_channel), do: "Unknown"

  defp message_room_id(message) when is_map(message) do
    normalize_string(
      Map.get(message, :room_id) ||
        Map.get(message, "room_id"),
      "unknown"
    )
  end

  defp message_room_id(_message), do: "unknown"

  defp message_actor(message) when is_map(message) do
    normalize_string(
      Map.get(message, :actor) ||
        Map.get(message, "actor") ||
        Map.get(message, :username) ||
        Map.get(message, "username"),
      "unknown"
    )
  end

  defp message_actor(_message), do: "unknown"

  defp message_channel_label(message) when is_map(message) do
    message
    |> Map.get(:channel, Map.get(message, "channel"))
    |> channel_to_string()
    |> binding_channel_label()
  end

  defp message_channel_label(_message), do: "Unknown"

  defp message_snippet(message) when is_map(message) do
    normalize_string(
      Map.get(message, :snippet) ||
        Map.get(message, "snippet") ||
        Map.get(message, :text) ||
        Map.get(message, "text"),
      "—"
    )
  end

  defp message_snippet(_message), do: "—"

  defp format_message_timestamp(message) when is_map(message) do
    message
    |> Map.get(:timestamp, Map.get(message, "timestamp"))
    |> format_timestamp_value()
  end

  defp format_message_timestamp(_message), do: "unknown time"

  defp format_timestamp_value(%DateTime{} = timestamp) do
    Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S UTC")
  end

  defp format_timestamp_value(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, value, _offset} -> format_timestamp_value(value)
      _other -> normalize_string(timestamp, "unknown time")
    end
  end

  defp format_timestamp_value(_timestamp), do: "unknown time"

  defp format_refreshed_at(%DateTime{} = refreshed_at) do
    Calendar.strftime(refreshed_at, "%Y-%m-%d %H:%M:%S UTC")
  end

  defp format_refreshed_at(_), do: "unknown"

  defp resolve_inventory_provider(session) when is_map(session) do
    case Map.get(session, "chatops_inventory_provider") || Map.get(session, :chatops_inventory_provider) do
      module when is_atom(module) -> module
      _other -> RoomInventory
    end
  end

  defp resolve_inventory_provider(_session), do: RoomInventory

  defp resolve_message_provider(session) when is_map(session) do
    case Map.get(session, "chatops_message_provider") || Map.get(session, :chatops_message_provider) do
      module when is_atom(module) -> module
      _other -> MessageTimeline
    end
  end

  defp resolve_message_provider(_session), do: MessageTimeline

  defp resolve_message_timeline_limit(session) when is_map(session) do
    case Map.get(session, "chatops_message_limit") || Map.get(session, :chatops_message_limit) do
      limit when is_integer(limit) and limit > 0 -> limit
      _other -> @default_message_timeline_limit
    end
  end

  defp resolve_message_timeline_limit(_session), do: @default_message_timeline_limit

  defp format_error({:inventory_exception, message}), do: message
  defp format_error({:messaging_exception, message}), do: message
  defp format_error({:inventory_exit, reason}), do: inspect(reason)
  defp format_error({:messaging_exit, reason}), do: inspect(reason)
  defp format_error(reason), do: inspect(reason)
end
