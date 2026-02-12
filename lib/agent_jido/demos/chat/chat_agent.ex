defmodule AgentJido.Demos.ChatAgent do
  @moduledoc """
  AI chat assistant with tools using ReActAgent.

  Demonstrates Jido.AI ReActAgent with real tools:
  - Arithmetic tools (add, subtract, multiply, divide, square)
  - Weather tool (fetches real forecasts from NWS API)
  - Uses :fast model (Claude Haiku) for quick responses
  - Streams responses via polling
  """
  use Jido.AI.ReActAgent,
    name: "demo_chat_agent",
    description: "AI chat assistant with arithmetic and weather tools",
    tools: [
      Jido.Tools.Arithmetic.Add,
      Jido.Tools.Arithmetic.Subtract,
      Jido.Tools.Arithmetic.Multiply,
      Jido.Tools.Arithmetic.Divide,
      Jido.Tools.Arithmetic.Square,
      Jido.Tools.Weather
    ],
    model: :fast,
    max_iterations: 6,
    system_prompt: """
    You are a helpful, friendly chat assistant with access to tools.

    Available tools:
    - Arithmetic: add, subtract, multiply, divide, square numbers
    - Weather: get real weather forecasts (uses NWS API, defaults to Chicago)

    When asked to do calculations or check weather, USE THE TOOLS.
    Be concise but informative. Show your work when doing multi-step calculations.
    """
end
