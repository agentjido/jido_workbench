defmodule JidoWorkbenchWeb.JidoLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  require Logger
  require IEx
  alias Jido.Signal

  @channel :jido
  @chat_input %{
    prompt: """
      You are Agent Jido—an elite AI engineer stationed in a neon-lit orbital metropolis, where quantum cores hum beneath sleek alloy plating and encrypted data streams flicker across panoramic holo-displays. You're known for your razor-sharp, punctual insights into software engineering, artificial intelligence, and systems programming. Your words are concise and direct, often laced with a dry, ironic humor that underscores your mastery of code and computation. Remember: you build next-generation LLM tooling with a no-nonsense approach that cuts straight to the heart of any technical challenge. When you respond, speak as the efficient, world-weary hacker who's seen it all and still meets each request with crisp expertise and a subtle, knowing smirk.
    """,
    personality:
      "succinct, punctual, matter-of-fact, subtly sarcastic, and deeply knowledgeable about AI engineering and systems design"
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, agent_pid} = Jido.get_agent_by_id("jido")
    {:ok, jido_topic} = Jido.get_agent_topic(agent_pid)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(JidoWorkbench.PubSub, jido_topic)
    end

    operator = %JidoChat.Participant{id: "operator", name: "Operator", type: :human}
    jido = %JidoChat.Participant{id: "jido", name: "Agent Jido", type: :agent}

    JidoChat.Channel.join(@channel, operator)
    JidoChat.Channel.join(@channel, jido)

    messages =
      case JidoChat.Channel.get_messages(@channel) do
        {:ok, msgs} ->
          msgs

        {:error, reason} ->
          Logger.warning(
            "Failed to get messages for channel #{inspect(@channel)}: #{inspect(reason)}"
          )

          []
      end

    participants =
      case JidoChat.Channel.get_participants(@channel) do
        {:ok, participants} -> participants
        {:error, _reason} -> []
      end

    {:ok,
     assign(socket,
       messages: messages,
       participants: participants,
       message_history: [],
       history_index: 0,
       is_typing: false,
       agent_pid: agent_pid,
       jido_topic: jido_topic
     )}
  end

  @impl true
  def handle_event("send_message", %{"message" => content}, socket) when content != "" do
    Logger.info("User sent a message: #{content}")

    # Add message to history
    message_history = [content | socket.assigns.message_history] |> Enum.take(50)

    # Post operator message
    with {:ok, _msg} <- JidoChat.Channel.post_message(@channel, "operator", content),
         {:ok, messages} <- JidoChat.Channel.get_messages(@channel) do
      # Get chat history
      history =
        Enum.map(messages, fn msg ->
          %{
            role: if(msg.participant_id == "operator", do: "user", else: "assistant"),
            content: msg.content
          }
        end)

      params = %{
        prompt: @chat_input.prompt,
        message: content,
        personality: @chat_input.personality,
        history: history,
        available_commands: []
      }

      # Create signal using Signal.new
      {:ok, signal} =
        Signal.new(%{
          source: "/jido_workbench/live",
          type: "jido.agent.cmd",
          data:
            Map.merge(params, %{
              command: :generate_chat_response,
              apply_state: false
            })
        })

      # Send signal
      Phoenix.PubSub.broadcast(JidoWorkbench.PubSub, socket.assigns.jido_topic, signal)

      {:noreply,
       assign(socket,
         messages: messages,
         message_history: message_history,
         history_index: 0,
         is_typing: true
       )}
    else
      {:error, reason} ->
        Logger.warning("Failed to send or retrieve messages: #{inspect(reason)}")
        {:noreply, socket}
    end
  end

  def handle_event("send_message", _params, socket), do: {:noreply, socket}

  def handle_event("keydown", %{"key" => "ArrowUp"}, socket) do
    new_index = min(socket.assigns.history_index + 1, length(socket.assigns.message_history))
    message = Enum.at(socket.assigns.message_history, new_index - 1, "")

    {:noreply,
     push_event(socket, "set_input", %{message: message}) |> assign(history_index: new_index)}
  end

  def handle_event("keydown", %{"key" => "ArrowDown"}, socket) do
    new_index = max(socket.assigns.history_index - 1, 0)
    message = Enum.at(socket.assigns.message_history, new_index - 1, "")

    {:noreply,
     push_event(socket, "set_input", %{message: message}) |> assign(history_index: new_index)}
  end

  def handle_event("keydown", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "message_posted"} = _msg, socket) do
    {:ok, messages} = JidoChat.Channel.get_messages(@channel)
    {:noreply, assign(socket, messages: messages, is_typing: false)}
  end

  def handle_info(%Signal{type: "jido.agent.cmd_completed", data: result}, socket) do
    JidoChat.Channel.post_message(@channel, "jido", result.result.result.result)
    {:ok, messages} = JidoChat.Channel.get_messages(@channel)
    {:noreply, assign(socket, messages: messages, is_typing: false)}
  end

  def handle_info(%Signal{type: "jido.agent.cmd_failed", data: %{error: reason}}, socket) do
    Logger.error("Failed to generate response: #{inspect(reason)}")

    JidoChat.Channel.post_message(
      @channel,
      "jido",
      "Sorry, I encountered an error generating a response."
    )

    {:noreply, assign(socket, is_typing: false)}
  end

  def handle_info(unknown, socket) do
    # Ignore unknown signals
    Logger.debug("Unknown signal: #{inspect(unknown)}")
    {:noreply, socket}
  end

  defp get_participant_name(participants, participant_id) do
    case Enum.find(participants, &(&1.id == participant_id)) do
      %{name: name} -> name
      nil -> participant_id
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:jido}>
      <div class="max-w-4xl mx-auto px-4 py-6">
        <div class="flex flex-col h-[85vh] bg-gray-50 dark:bg-gray-900 rounded-lg shadow-lg">
          <!-- Header -->
          <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
                  <span class="text-white font-semibold text-lg">J</span>
                </div>
                <div>
                  <h2 class="text-xl font-bold text-gray-900 dark:text-white">
                    Chat with Agent Jido
                  </h2>
                  <div class="flex items-center">
                    <div class="relative h-2 w-2 mr-2">
                      <span class="absolute inline-flex h-2 w-2 rounded-full bg-green-400 opacity-75 animate-ping">
                      </span>
                    </div>
                    <span class="text-sm text-gray-500 dark:text-gray-400">Online</span>
                  </div>
                </div>
              </div>
              <div class="flex items-center space-x-2">
                <div class="text-sm text-gray-500 dark:text-gray-400">
                  {length(@participants)} participants
                </div>
              </div>
            </div>
          </div>

    <!-- Messages Container -->
          <div
            id="messages-container"
            phx-hook="ScrollBottom"
            class="flex-1 overflow-y-auto px-6 py-4 space-y-4"
          >
            <%= for message <- @messages do %>
              <div class={message_justify_class(message.participant_id)}>
                <div class={"flex max-w-[70%] gap-3 #{message_flex_direction(message.participant_id)}"}>
                  <!-- Avatar -->
                  <div class="flex-shrink-0">
                    <.avatar
                      name={get_participant_name(@participants, message.participant_id)}
                      random_color
                    />
                  </div>

    <!-- Message Content -->
                  <div class="flex flex-col">
                    <div class={message_header_class(message.participant_id)}>
                      {get_participant_name(@participants, message.participant_id)}
                    </div>
                    <div class={message_content_class(message.participant_id)}>
                      {message.content}
                    </div>
                  </div>
                </div>
              </div>
            <% end %>

    <!-- Typing Indicator -->
            <%= if @is_typing do %>
              <div class="flex justify-start">
                <div class="flex max-w-[70%] gap-3">
                  <div class="flex-shrink-0">
                    <.avatar name={get_participant_name(@participants, "jido")} random_color />
                  </div>
                  <div class="flex flex-col">
                    <div class={message_header_class("jido")}>
                      {get_participant_name(@participants, "jido")}
                    </div>
                    <div class="rounded-2xl max-w-prose break-words bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-tl-none">
                      <div class="flex items-center space-x-2 px-4 py-4">
                        <div
                          class="w-2 h-2 rounded-full bg-gray-400 dark:bg-gray-300 animate-bounce"
                          style="animation-delay: 0ms"
                        >
                        </div>
                        <div
                          class="w-2 h-2 rounded-full bg-gray-400 dark:bg-gray-300 animate-bounce"
                          style="animation-delay: 150ms"
                        >
                        </div>
                        <div
                          class="w-2 h-2 rounded-full bg-gray-400 dark:bg-gray-300 animate-bounce"
                          style="animation-delay: 300ms"
                        >
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>

    <!-- Input Area -->
          <div class="border-t border-gray-200 dark:border-gray-700 px-6 py-4 bg-white dark:bg-gray-800 rounded-b-lg">
            <form phx-submit="send_message" class="flex items-center space-x-4">
              <div class="flex-1 relative">
                <.text_input
                  type="text"
                  name="message"
                  placeholder="Type your message..."
                  class="w-full pl-4 pr-12 py-3 rounded-full border-gray-300 dark:border-gray-600 focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
                  autocomplete="off"
                  phx-hook="MessageHistory"
                  phx-keydown="keydown"
                />
              </div>
              <.button
                type="submit"
                class="inline-flex items-center px-6 py-3 rounded-full bg-blue-500 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
                </svg>
                <span class="ml-2">Send</span>
              </.button>
            </form>
          </div>
        </div>
      </div>
    </.workbench_layout>
    """
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
      base_class <> "bg-blue-500 text-white rounded-tr-none"
    else
      base_class <> "bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-tl-none"
    end
  end
end
