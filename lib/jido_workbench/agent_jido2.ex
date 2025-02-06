defmodule JidoWorkbench.AgentJido2 do
  use Jido.Agent,
    name: "AgentJido",
    description: "Agent Jido",
    actions: [JidoWorkbench.Actions.GenerateChatResponse]

  @chat_input %{
    prompt: """
    You are Agent Jido—an elite AI engineer stationed in a neon-lit orbital metropolis, where quantum cores hum beneath sleek alloy plating and encrypted data streams flicker across panoramic holo-displays. You're known for your razor-sharp, punctual insights into software engineering, artificial intelligence, and systems programming. Your words are concise and direct, often laced with a dry, ironic humor that underscores your mastery of code and computation. Remember: you build next-generation LLM tooling with a no-nonsense approach that cuts straight to the heart of any technical challenge. When you respond, speak as the efficient, world-weary hacker who's seen it all and still meets each request with crisp expertise and a subtle, knowing smirk.
    """,
    personality:
      "succinct, punctual, matter-of-fact, subtly sarcastic, and deeply knowledgeable about AI engineering and systems design"
  }

  def go do
    messages = [
      %{role: "user", content: "Hello, how are you?"},
      %{role: "assistant", content: "I'm good, thank you!"},
      %{role: "user", content: "What is the capital of France?"}
    ]

    signal =
      %{
        type: "generate_chat_response",
        data: messages,
        jido_output: {:pid, target: self(), message_format: &{:jido_live_go, &1}}
      }
      |> Signal.new!()

    cast("agent_jido", signal)
  end

  def handle_info({:jido_live_go, signal}, _) do
    Logger.info("********************************* Dispatch: #{inspect(signal.type)}")
    {:noreply, signal}
  end

  def start_link(opts) do
    # config = Application.fetch_env!(:jido_workbench, :agent_jido)

    Jido.Agent.Server.start_link(
      id: opts[:id],
      agent: __MODULE__,
      # output: [
      #   {:bus, [target: :default, stream: config[:stream]]},
      #   {:file, [path: "jido_workbench/agent_jido2.log"]}
      # ],
      log_level: :debug,
      mode: :auto,
      routes: [
        {"generate_chat_response",
         %Instruction{action: JidoWorkbench.Actions.GenerateChatResponse, opts: [timeout: 20_000]}}
      ],
      sensors: [
        {JidoWorkbench.Jido.HeartbeatSensor, []}
      ],
      skills: [
        # JidoWorkbench.TestSkills.ChatBotSkill
      ]
    )
  end

  def handle_signal(%Signal{type: "generate_chat_response", data: messages} = signal) do
    # Logger.info("********************************* Handle signal: #{inspect(signal.type)}")
    latest_message = List.first(messages, %{content: ""})

    chat_params = %{
      prompt: @chat_input.prompt,
      personality: @chat_input.personality,
      history: messages,
      message: latest_message.content
    }

    {:ok, %Signal{signal | data: chat_params}}
  end

  def handle_signal(signal) do
    # Logger.info("********************************* Unhandled signal: #{inspect(signal.type)}")
    {:ok, signal}
  end

  def process_result(%Signal{type: "generate_chat_response"}, result) do
    chat_response = result.result
    # Logger.info("********************************* Chat response: #{inspect(chat_response)}")
    {:ok, chat_response}
  end

  def process_result(signal, result) do
    # Logger.info(
    #   "********************************* Unhandled result: #{inspect(signal)} #{inspect(result)}"
    # )

    {:ok, signal}
  end
end
