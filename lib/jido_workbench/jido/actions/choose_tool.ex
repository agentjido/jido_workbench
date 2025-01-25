defmodule JidoWorkbench.Jido.ChooseTool do
  require Logger

  use Jido.Action,
    name: "choose_tool",
    description: "Choose which tool to use based on the user's message and specify parameters",
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
        default: "claude-3-haiku-20240307",
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
    available_tools = [
      Jido.Actions.Arithmetic.Add,
      Jido.Actions.Arithmetic.Subtract
    ]

    Jido.Workflow.run(
      __MODULE__,
      %{
        message: "What is 1 - 1?",
        available_tools: available_tools,
        temperature: 0.1
      }
    )
  end

  def run(params, context) do
    Logger.metadata(action: "choose_tool")
    Logger.debug("Starting tool selection", params: inspect(params))

    # Build tool registry
    tool_registry = build_tool_registry(params.available_tools)

    messages = [
      Message.new_system!("""
        You are a helpful assistant that chooses the most appropriate tool for a task and specifies its parameters.
        Available tools:
        #{format_tools(tool_registry)}

        IMPORTANT: Only select a tool if it EXACTLY matches what is needed for the task.
        If no tool precisely fits the requirements, or if you are unsure, respond with:
        {
          "tool": "none",
          "reason": "Brief explanation of why no tool fits"
        }

        Otherwise, respond in JSON format with:
        1. The name of the most appropriate tool module (fully qualified)
        2. The parameters to use with that tool

        Example responses:
        {
          "tool": "Jido.Actions.Arithmetic.Add",
          "parameters": {
            "value": "5",
            "amount": "3"
          }
        }

        OR

        {
          "tool": "none",
          "reason": "No tool available for multiplication operations"
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

        case Jason.decode(chain.last_message.content) do
          {:ok, %{"tool" => "none", "reason" => reason}} ->
            Logger.info("No suitable tool found", reason: reason)
            {:error, :invalid_tool}

          {:ok, %{"tool" => tool_name, "parameters" => tool_params}} ->
            tool_module = resolve_tool_module(tool_name, tool_registry)

            case tool_module do
              nil ->
                Logger.warning("Invalid tool selected", tool: tool_name)
                {:error, :invalid_tool}

              module ->
                directive = %Jido.Agent.Directive.EnqueueDirective{
                  action: module,
                  params: tool_params,
                  context: context,
                  opts: []
                }

                {:ok, directive}
            end

          {:error, reason} ->
            Logger.warning("Failed to parse tool selection response",
              response: chain.last_message.content,
              error: inspect(reason)
            )

            {:error, :invalid_response}
        end
      end)

    try do
      case Task.yield(task, 29_000) || Task.shutdown(task, :brutal_kill) do
        {:ok, {:ok, directive}} ->
          Logger.info("Generated directive", directive: inspect(directive))
          {:ok, %{result: directive}}

        {:ok, {:error, reason}} ->
          {:error, reason}

        nil ->
          Logger.warning("Tool selection timed out")
          {:error, :timeout}
      end
    catch
      kind, reason ->
        Logger.warning("Unexpected error in tool selection",
          kind: kind,
          error: inspect(reason),
          stacktrace: __STACKTRACE__
        )

        {:error, reason}
    end
  end

  defp build_tool_registry(modules) do
    modules
    |> Enum.map(fn module ->
      tool = module.to_tool()
      {to_string(module), tool}
    end)
    |> Map.new()
  end

  defp format_tools(tool_registry) do
    tool_registry
    |> Enum.map(fn {module_name, tool} ->
      """
      - #{module_name}: #{tool.description}
        Parameters:
        #{format_parameters(tool.parameters_schema)}
      """
    end)
    |> Enum.join("\n")
  end

  defp format_parameters(%{type: "object", properties: properties, required: required}) do
    properties
    |> Enum.map(fn {name, %{type: type, description: desc}} ->
      required_text = if name in required, do: "(required)", else: "(optional)"
      "  * #{name} (#{type}) #{required_text}: #{desc}"
    end)
    |> Enum.join("\n")
  end

  defp resolve_tool_module(tool_name, tool_registry) do
    case Map.get(tool_registry, tool_name) do
      nil -> nil
      _tool -> String.to_existing_atom(tool_name)
    end
  end
end
