defmodule JidoWorkbenchWeb.JidoLive2 do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  import JidoWorkbenchWeb.ChatComponents
  alias JidoWorkbench.AgentJido2
  alias Jido.Chat.{Room, Message, Participant}
  alias Jido.Signal
  require Logger

  @response_timeout :timer.seconds(30)
  @agent_id Application.compile_env(:jido_workbench, [:agent_jido, :id])
  @bus_name Application.compile_env(:jido_workbench, [:agent_jido, :bus_name])
  @room_id Application.compile_env(:jido_workbench, [:agent_jido, :room_id])

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
    socket = assign(socket, is_typing: true)

    history =
      Enum.map(socket.assigns.messages, fn msg ->
        %{
          role: if(Message.sender_id(msg) == "operator", do: "user", else: "assistant"),
          content: Message.content(msg)
        }
      end)

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
  def handle_info({:jido_live, %Signal{data: response, source: message_id}}, socket) do
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

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:jido}>
      <div class="max-w-4xl mx-auto px-4 py-6">
        <.chat_container messages={@messages} is_typing={@is_typing}>
          <:input_form>
            <form phx-submit="send_message" class="flex gap-2">
              <input
                type="text"
                name="message"
                placeholder="Type a message..."
                class="flex-1 bg-zinc-800 text-gray-100 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-lime-500"
                autocomplete="off"
              />
              <button
                type="submit"
                class="bg-lime-500 text-zinc-900 rounded-lg px-4 py-2 font-semibold hover:bg-lime-400 focus:outline-none focus:ring-2 focus:ring-lime-500"
              >
                Send <.icon name="hero-paper-airplane" class="h-5 w-5" />
              </button>
            </form>
          </:input_form>
        </.chat_container>
      </div>
    </.workbench_layout>
    """
  end
end
