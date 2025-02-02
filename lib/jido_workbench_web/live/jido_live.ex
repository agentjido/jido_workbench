defmodule JidoWorkbenchWeb.JidoLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.AgentJido
  alias Jido.Chat.{Room, Message, Participant}
  require Logger

  @agent_id "sync_jido"
  @bus_name Application.compile_env(:jido_workbench, [:agent_jido, :bus_name])
  @room_id Application.compile_env(:jido_workbench, [:agent_jido, :room_id])

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, room} <- Room.resolve_room(@bus_name, @room_id),
         {:ok, participant} <- Participant.new("operator", :human, display_name: "Operator"),
         _ <- Room.add_participant(room, participant),
         {:ok, messages} <- Room.get_messages(room) do
      {:ok,
       assign(socket,
         room: room,
         messages: messages,
         message_history: [],
         history_index: 0,
         is_typing: false,
         agent: @agent_id,
         response_ref: nil
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

    # Start async task to get response
    task =
      Task.async(fn ->
        AgentJido.generate_chat_response(@agent_id, history)
      end)

    {:noreply, assign(socket, response_ref: task.ref)}
  end

  @impl true
  def handle_info({ref, {:ok, response}}, %{assigns: %{response_ref: ref}} = socket) do
    # Clean up task
    Process.demonitor(ref, [:flush])

    {:ok, _} = Room.post_message(socket.assigns.room, response, "jido")
    {:ok, messages} = Room.get_messages(socket.assigns.room)

    {:noreply,
     socket
     |> assign(is_typing: false, response_ref: nil, messages: messages, history_index: 0)}
  end

  def handle_info({ref, {:error, reason}}, %{assigns: %{response_ref: ref}} = socket) do
    # Clean up task
    Process.demonitor(ref, [:flush])
    Logger.error("Chat response failed: #{inspect(reason)}")

    {:ok, _} =
      Room.post_message(
        socket.assigns.room,
        "Sorry, I encountered an error. Please try again in a moment.",
        "jido",
        type: :system
      )

    {:ok, messages} = Room.get_messages(socket.assigns.room)

    {:noreply,
     socket
     |> assign(is_typing: false, response_ref: nil, messages: messages, history_index: 0)}
  end

  # Handle task crash
  def handle_info({:DOWN, ref, :process, _pid, reason}, %{assigns: %{response_ref: ref}} = socket) do
    Logger.error("Chat response task crashed: #{inspect(reason)}")

    {:ok, _} =
      Room.post_message(
        socket.assigns.room,
        "Sorry, something went wrong. Please try again in a moment.",
        "jido",
        type: :system
      )

    {:ok, messages} = Room.get_messages(socket.assigns.room)

    {:noreply,
     socket
     |> assign(is_typing: false, response_ref: nil, messages: messages, history_index: 0)}
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
