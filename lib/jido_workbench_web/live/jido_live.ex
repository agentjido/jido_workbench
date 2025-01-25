defmodule JidoWorkbenchWeb.JidoLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  require Logger
  alias JidoWorkbench.Jido.ChatAgent

  @chat_input %{
    prompt: """
      You are Agent Jido—an elite AI engineer stationed in a neon-lit orbital metropolis, where quantum cores hum beneath sleek alloy plating and encrypted data streams flicker across panoramic holo-displays. You're known for your razor-sharp, punctual insights into software engineering, artificial intelligence, and systems programming. Your words are concise and direct, often laced with a dry, ironic humor that underscores your mastery of code and computation. Remember: you build next-generation LLM tooling with a no-nonsense approach that cuts straight to the heart of any technical challenge. When you respond, speak as the efficient, world-weary hacker who's seen it all and still meets each request with crisp expertise and a subtle, knowing smirk.
    """,
    personality:
      "succinct, punctual, matter-of-fact, subtly sarcastic, and deeply knowledgeable about AI engineering and systems design"
  }

  @impl true
  def mount(_params, _session, socket) do
    agent = ChatAgent.new(UUID.uuid4(), %{messages: []})
    initial_message = format_message("jido", "Hello, I'm Jido, what's your name?")

    {:ok,
     assign(socket,
       messages: [initial_message],
       message_history: [],
       history_index: 0,
       is_typing: false,
       agent: agent
     )}
  end

  def handle_event("send_message", %{"message" => content}, socket) when content != "" do
    Logger.info("User sent a message: #{content}")
    socket = add_user_message(socket, content)
    process_chat_response(socket)
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

  defp add_user_message(socket, content) do
    message_history = [content | socket.assigns.message_history] |> Enum.take(50)
    messages = socket.assigns.messages ++ [format_message("operator", content)]
    assign(socket, messages: messages, message_history: message_history)
  end

  defp process_chat_response(socket) do
    history = build_chat_history(socket.assigns.messages)
    params = build_chat_params(history)
    agent = socket.assigns.agent

    case agent
         |> ChatAgent.set(params)
         |> ChatAgent.plan()
         |> ChatAgent.run() do
      {:ok, %{response: response}, _agent} ->
        updated_messages = socket.assigns.messages ++ [format_message("jido", response)]
        {:noreply, assign(socket, messages: updated_messages, is_typing: false, history_index: 0)}

      {:error, reason} ->
        Logger.error("Chat response failed: #{inspect(reason)}")

        error_message =
          format_message("jido", "Sorry, I encountered an error. Please try again in a moment.")

        {:noreply,
         assign(socket, messages: socket.assigns.messages ++ [error_message], is_typing: false)}
    end
  end

  defp build_chat_history(messages) do
    Enum.map(messages, fn msg ->
      %{
        role: if(msg.participant_id == "operator", do: "user", else: "assistant"),
        content: msg.content
      }
    end)
  end

  defp build_chat_params(history) do
    %{
      prompt: @chat_input.prompt,
      personality: @chat_input.personality,
      history: history,
      message: List.first(history, %{content: ""}).content
    }
  end

  defp format_message(participant_id, content) do
    formatted_content =
      content
      |> String.trim()
      |> format_code_blocks()
      |> format_line_breaks()

    %{
      participant_id: participant_id,
      content: formatted_content,
      timestamp: DateTime.utc_now()
    }
  end

  defp format_code_blocks(content) do
    Regex.replace(~r/```(\w*)\n(.*?)```/s, content, fn _, lang, code ->
      """
      <div class="code-block">
        <div class="code-header">#{lang}</div>
        <pre><code class="language-#{lang}">#{code}</code></pre>
      </div>
      """
    end)
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
