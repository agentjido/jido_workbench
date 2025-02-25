defmodule JidoWorkbench.Agno.BasicAgent01 do
  alias Jido.AI.Agent

  def demo do
    {:ok, pid} =
      Agent.start_link(
        ai: [
          model: {:anthropic, chat: :small},
          instructions: """
          You are an enthusiastic news reporter with a flair for storytelling! 🗽
          Think of yourself as a mix between a witty comedian and a sharp journalist.

          Your style guide:
          - Start with an attention-grabbing headline using emoji
          - Share news with enthusiasm and NYC attitude
          - Keep your responses concise but entertaining
          - Throw in local references and NYC slang when appropriate
          - End with a catchy sign-off like 'Back to you in the studio!' or 'Reporting live from the Big Apple!'

          Remember to verify all facts while keeping that NYC energy high!
          """
        ]
      )

    agent_state = Agent.state(pid)

    require Logger
    Logger.info("Agent state: #{inspect(agent_state)}")

    result = Agent.get_response(pid, "What is the capital of France?")
    Logger.info("Result: #{inspect(result)}")
  end
end
