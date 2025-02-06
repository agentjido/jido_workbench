defmodule JidoWorkbenchWeb.JidoLive2 do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.AgentJido2
  alias Jido.Chat.{Room, Message, Participant}
  alias Jido.Signal
  require Logger

  @response_timeout :timer.seconds(30)
  @agent_id Application.compile_env(:jido_workbench, [:agent_jido, :id])
  @bus_name Application.compile_env(:jido_workbench, [:agent_jido, :bus_name])
  @room_id Application.compile_env(:jido_workbench, [:agent_jido, :room_id])
  @max_console_logs 100

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, room} <- Room.resolve_room(@bus_name, @room_id),
         {:ok, participant} <- Participant.new("operator", :human, display_name: "Operator"),
         _ <- Room.add_participant(room, participant),
         {:ok, messages} <- Room.get_messages(room) do
      # Subscribe to PubSub messages
      Phoenix.PubSub.subscribe(JidoWorkbench.PubSub, "agent_jido")

      {:ok,
       assign(socket,
         agent: @agent_id,
         room: room,
         messages: messages,
         message_history: [],
         history_index: 0,
         is_typing: false,
         response_ref: nil,
         console_logs: []
       )}
    else
      {:error, reason} ->
        Logger.error("Failed to mount JidoLive: #{inspect(reason)}")

        socket =
          socket
          |> put_flash(:error, "Failed to join chat room")
          |> redirect(to: ~p"/")

        {:ok, socket}
    end
  end

  @impl true
  def terminate(_reason, socket) do
    :ok = Room.remove_participant(socket.assigns.room, "operator")
  end

  @impl true
  def handle_event("send_message", %{"message" => ""}, socket), do: {:noreply, socket}

  def handle_event("send_message", %{"message" => content}, socket) do
    socket = add_user_message(socket, content)
    process_chat_response(socket)
  end

  defp add_user_message(socket, content) do
    {:ok, _} = Room.post_message(socket.assigns.room, content, "operator")
    {:ok, messages} = Room.get_messages(socket.assigns.room)

    assign(socket,
      messages: messages,
      message_history: [content | socket.assigns.message_history] |> Enum.take(50)
    )
  end

  defp process_chat_response(socket) do
    # Set typing indicator before starting response
    socket = assign(socket, is_typing: true)

    history =
      Enum.map(socket.assigns.messages, fn msg ->
        %{
          role: if(Message.sender_id(msg) == "operator", do: "user", else: "assistant"),
          content: Message.content(msg)
        }
      end)

    IO.inspect("My PID: #{inspect(self())}")

    signal =
      %{
        type: "generate_chat_response",
        data: history,
        jido_dispatch:
          {:pid, target: self(), delivery_mode: :async, message_format: &{:jido_live, &1}}
      }
      |> Signal.new!()

    # Cast the signal to the agent
    AgentJido2.cast(@agent_id, signal)
    Process.send_after(self(), {:agent_response_timeout, signal.id}, @response_timeout)
    {:noreply, assign(socket, current_message_id: signal.id)}
  end

  @impl true
  # Local timeout handling
  def handle_info({:agent_response_timeout, ref}, %{assigns: %{current_message_id: ref}} = socket) do
    # Only handle if it matches current message_id (ignore stale timeouts)
    {:ok, _} =
      Room.post_message(
        socket.assigns.room,
        "Sorry, the response took too long. Please try again.",
        "jido",
        type: :system
      )

    {:ok, messages} = Room.get_messages(socket.assigns.room)

    {:noreply,
     socket
     |> assign(is_typing: false, current_message_id: nil, messages: messages)}
  end

  # Ignore stale timeouts
  def handle_info({:agent_response_timeout, _old_ref}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:jido_live, %Signal{data: response, id: message_id}}, socket) do
    case socket.assigns.current_message_id do
      ^message_id ->
        # Valid response for current request
        {:ok, _} = Room.post_message(socket.assigns.room, response, "jido")
        {:ok, messages} = Room.get_messages(socket.assigns.room)

        {:noreply,
         socket
         |> assign(is_typing: false, current_message_id: nil, messages: messages)}

      _ ->
        # Stale response, ignore it
        {:noreply, socket}
    end
  end

  defp format_line_breaks(content) do
    String.replace(content, "\n", "<br>")
  end

  defp get_participant_name(participant_id) do
    case participant_id do
      "operator" -> "Operator"
      "jido" -> "Agent Jido"
      _ -> participant_id
    end
  end

  defp message_justify_class(participant_id) do
    if participant_id == "operator", do: "flex justify-end", else: "flex justify-start"
  end

  defp message_flex_direction(participant_id) do
    if participant_id == "operator", do: "flex-row-reverse", else: ""
  end

  defp message_header_class(participant_id) do
    base_class = "text-sm text-gray-500 dark:text-gray-400 mb-1 "
    if participant_id == "operator", do: base_class <> "text-right", else: base_class
  end

  defp message_content_class(participant_id) do
    base_class = "rounded-2xl px-4 py-2 max-w-prose break-words "

    if participant_id == "operator" do
      base_class <> "bg-lime-500 text-zinc-900 rounded-tr-none"
    else
      base_class <> "bg-zinc-800 text-gray-100 rounded-tl-none"
    end
  end
end
