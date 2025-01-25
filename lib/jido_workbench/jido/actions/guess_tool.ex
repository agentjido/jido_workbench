defmodule JidoWorkbench.Jido.GuessTool do
  require Logger

  use Jido.Action,
    name: "guess_tool",
    description:
      "Analyze a user request and either match it to an available tool or propose an ideal tool design",
    schema: [
      message: [type: :string, required: true, doc: "The user's message"],
      available_tools: [
        type: {:list, :atom},
        required: true,
        doc: "List of available tool modules"
      ],
      temperature: [
        type: :float,
        required: false,
        default: 0.2,
        doc:
          "Temperature for LLM response randomness (0.0-1.0). Lower values are more deterministic."
      ],
      model: [
        type: :string,
        required: false,
        default: "claude-3-5-haiku-latest",
        doc: "The model to use for tool selection"
      ],
      verbose: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Whether to enable verbose logging"
      ]
    ]

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias LangChain.Message

  def test do
    params = %{
      message: "What is the square root of 16?",
      available_tools: [
        Jido.Actions.Arithmetic.Add,
        Jido.Actions.Arithmetic.Subtract
      ],
      temperature: 0.1
    }

    Jido.Workflow.run(__MODULE__, params, %{})
  end

  def run(params, context) do
    Logger.metadata(action: "guess_tool")
    Logger.debug("Starting tool guessing #{inspect(params)}")

    # First try to choose from available tools
    case JidoWorkbench.Jido.ChooseTool.run(params, context) do
      {:ok, %{result: directive}} ->
        Logger.info("Found matching tool", tool: inspect(directive.action))
        {:ok, %{result: %{found: true, directive: directive}}}

      {:error, :invalid_tool} ->
        Logger.info("No matching tool found, attempting to speculate ideal tool")
        # If no valid tool found, speculate about ideal tool
        speculate_ideal_tool(params, context)

      {:error, reason} ->
        Logger.warning("Tool selection failed", error: inspect(reason))
        {:error, reason}
    end
  end

  defp speculate_ideal_tool(params, context) do
    messages = [
      Message.new_system!("""
        You are a tool design specialist focused on creating precise, single-purpose tools to solve user requests.

        Your task is to analyze the user's request and design ONE ideal tool that would solve it completely.
        If the request requires multiple operations, explain this in the description but focus on designing
        the primary tool needed.

        Guidelines for tool design:
        1. Each tool should have ONE clear responsibility
        2. Parameters should be minimal but sufficient
        3. The tool name should clearly indicate its purpose
        4. The description should explain both what it does and when it should be used
        5. If the request is unclear or too vague, respond with a failure message

        Respond in JSON format with one of these structures:

        For a valid tool design:
        {
          "status": "success",
          "tool_name": "A clear, descriptive name for the tool",
          "description": "What the tool does, when to use it, and any important context about its operation",
          "parameters": {
            "param1": "Description of first parameter",
            "param2": "Description of second parameter"
          },
          "example": "A concrete example of how the tool would be used",
          "complexity_note": "Optional - if request needs multiple tools, briefly explain why"
        }

        For an invalid or unclear request:
        {
          "status": "error",
          "reason": "A clear explanation of why a tool cannot be designed",
          "suggestions": ["Optional list of clarifying questions or suggestions"]
        }

        Example success response:
        {
          "status": "success",
          "tool_name": "MultiplyNumbers",
          "description": "Performs multiplication of two numbers with decimal precision. Use when you need to multiply exactly two numeric values.",
          "parameters": {
            "multiplicand": "The first number to multiply",
            "multiplier": "The second number to multiply"
          },
          "example": "multiply_numbers(multiplicand: 3.14, multiplier: 2)",
          "complexity_note": null
        }

        Example error response:
        {
          "status": "error",
          "reason": "The request is too vague to design a specific tool",
          "suggestions": [
            "What specific operation needs to be performed?",
            "What type of data needs to be processed?"
          ]
        }
      """),
      Message.new_user!(params.message)
    ]

    chat_model =
      ChatAnthropic.new!(%{
        model: params.model,
        temperature: params.temperature
      })

    task =
      Task.Supervisor.async_nolink(JidoWorkbench.TaskSupervisor, fn ->
        {:ok, chain} =
          %{llm: chat_model, verbose: params.verbose}
          |> LLMChain.new!()
          |> LLMChain.add_messages(messages)
          |> LLMChain.run()

        Logger.debug("Received LLM response", response: chain.last_message.content)

        case Jason.decode(chain.last_message.content) do
          {:ok, %{"status" => "success"} = speculation} ->
            Logger.info("Successfully speculated tool design",
              tool_name: speculation["tool_name"],
              parameters: inspect(speculation["parameters"])
            )

            {:ok, %{found: false, speculation: speculation}}

          {:ok, %{"status" => "error", "reason" => reason, "suggestions" => suggestions}} ->
            Logger.info("Tool speculation failed",
              reason: reason,
              suggestions: inspect(suggestions)
            )

            {:error, {:invalid_request, reason}}

          {:ok, %{"status" => "error", "reason" => reason}} ->
            Logger.info("Tool speculation failed", reason: reason)
            {:error, {:invalid_request, reason}}

          {:error, reason} ->
            Logger.warning("Failed to parse tool speculation",
              response: chain.last_message.content,
              error: inspect(reason)
            )

            {:error, :invalid_response}
        end
      end)

    try do
      case Task.yield(task, 29_000) || Task.shutdown(task, :brutal_kill) do
        {:ok, {:ok, result}} ->
          {:ok, %{result: result}}

        {:ok, {:error, reason}} ->
          {:error, reason}

        nil ->
          Logger.warning("Tool speculation timed out")
          {:error, :timeout}
      end
    catch
      kind, reason ->
        Logger.warning("Unexpected error in tool speculation",
          kind: kind,
          error: inspect(reason),
          stacktrace: __STACKTRACE__
        )

        {:error, reason}
    end
  end
end
