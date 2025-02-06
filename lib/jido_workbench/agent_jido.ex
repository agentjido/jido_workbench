defmodule JidoWorkbench.AgentJido do
  alias Jido.Actions.Directives.{EnqueueAction, RegisterAction}
  alias JidoWorkbench.Actions.GenerateChatResponse
  alias Jido.Signal
  alias Jido.Agent.Server.Signal, as: ServerSignal
  alias Jido.Instruction

  use Jido.Agent,
    name: "AgentJido",
    description: "Agent Jido",
    actions: [GenerateChatResponse, EnqueueAction, RegisterAction]

  require Logger

  @chat_input %{
    prompt: """
    You are Agent Jido—an elite AI engineer stationed in a neon-lit orbital metropolis, where quantum cores hum beneath sleek alloy plating and encrypted data streams flicker across panoramic holo-displays. You're known for your razor-sharp, punctual insights into software engineering, artificial intelligence, and systems programming. Your words are concise and direct, often laced with a dry, ironic humor that underscores your mastery of code and computation. Remember: you build next-generation LLM tooling with a no-nonsense approach that cuts straight to the heart of any technical challenge. When you respond, speak as the efficient, world-weary hacker who's seen it all and still meets each request with crisp expertise and a subtle, knowing smirk.
    """,
    personality:
      "succinct, punctual, matter-of-fact, subtly sarcastic, and deeply knowledgeable about AI engineering and systems design"
  }

  def generate_chat_response(agent, messages) do
    # Get the latest user message
    latest_message = List.first(messages, %{content: ""})

    # Build the chat parameters
    chat_params = %{
      prompt: @chat_input.prompt,
      personality: @chat_input.personality,
      history: messages,
      message: latest_message.content
    }

    # Create the signal with proper action format
    {:ok, signal} =
      Signal.new(%{
        type: ServerSignal.join_type(ServerSignal.type({:cmd, :run})),
        source: "jido_chat",
        data: %{},
        jido_instructions: [
          %Instruction{action: GenerateChatResponse, params: chat_params, opts: [timeout: 20_000]}
        ],
        jido_opts: %{apply_state: true}
      })

    with {:ok, pid} <- Jido.resolve_pid(agent),
         {:ok, response} <- call(pid, signal, 20_000) do
      chat_response = response.result
      {:ok, chat_response}
    end
  end
end
