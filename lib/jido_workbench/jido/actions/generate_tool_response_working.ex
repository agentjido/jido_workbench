# defmodule JidoWorkbench.Actions.GenerateToolResponse do
#   require Logger

#   use Jido.Action,
#     name: "generate_tool_response",
#     description: "Generate a response using LangChain to coordinate with arithmetic actions",
#     schema: [
#       prompt: [type: :string, required: true, doc: "The prompt to use for the response"],
#       message: [type: :string, required: true, doc: "The user's message"],
#       personality: [type: :string, required: true, doc: "The personality of the assistant"]
#     ]

#   alias LangChain.Chains.LLMChain
#   alias LangChain.ChatModels.ChatAnthropic
#   alias LangChain.Message
#   alias LangChain.Function
#   alias Jido.Actions.Arithmetic.{Add, Subtract}

#   def run(params, context) do
#     Logger.metadata(action: "generate_tool_response")
#     Logger.debug("Starting tool response generation", params: inspect(params))

#     # Define arithmetic functions that can be called by the LLM
#     add_function =
#       Function.new!(%{
#         name: "add_numbers",
#         description: "Add two numbers together",
#         parameters_schema: %{
#           "type" => "object",
#           "properties" => %{
#             "value" => %{"type" => "number", "description" => "First number"},
#             "amount" => %{"type" => "number", "description" => "Second number"}
#           },
#           "required" => ["value", "amount"]
#         },
#         function: fn %{"value" => value, "amount" => amount}, _context ->
#           case Add.run(%{value: value, amount: amount}, context) do
#             {:ok, %{result: sum}} -> {:ok, Jason.encode!(%{sum: sum})}
#             error -> {:error, "Addition failed: #{inspect(error)}"}
#           end
#         end
#       })

#     subtract_function =
#       Function.new!(%{
#         name: "subtract_numbers",
#         description: "Subtract the second number from the first",
#         parameters_schema: %{
#           "type" => "object",
#           "properties" => %{
#             "value" => %{"type" => "number", "description" => "First number"},
#             "amount" => %{"type" => "number", "description" => "Second number"}
#           },
#           "required" => ["value", "amount"]
#         },
#         function: fn %{"value" => value, "amount" => amount}, _context ->
#           case Subtract.run(%{value: value, amount: amount}, context) do
#             {:ok, %{result: difference}} -> {:ok, Jason.encode!(%{difference: difference})}
#             error -> {:error, "Subtraction failed: #{inspect(error)}"}
#           end
#         end
#       })

#     # Create messages for the LLM
#     messages = [
#       Message.new_system!("""
#         You are a helpful math assistant that can perform arithmetic operations.
#         When asked about addition or subtraction, use the appropriate function to calculate the result.
#         #{params.personality}
#       """),
#       Message.new_user!(params.message)
#     ]

#     # Setup the LLM chain
#     chat_model =
#       ChatAnthropic.new!(%{
#         model: "claude-3-5-haiku-latest",
#         temperature: 0.7
#       })

#     task =
#       Task.Supervisor.async_nolink(JidoWorkbench.TaskSupervisor, fn ->
#         {:ok, chain} =
#           %{llm: chat_model, verbose: true}
#           |> LLMChain.new!()
#           |> LLMChain.add_messages(messages)
#           |> LLMChain.add_tools([add_function, subtract_function])
#           |> LLMChain.run(mode: :while_needs_response)

#         chain.last_message.content
#       end)

#     try do
#       case Task.yield(task, 29_000) || Task.shutdown(task, :brutal_kill) do
#         {:ok, response} ->
#           {:ok, %{result: response}}

#         nil ->
#           Logger.warning("Tool response generation timed out")
#           {:error, :timeout}
#       end
#     catch
#       kind, reason ->
#         Logger.warning("Unexpected error in tool response generation",
#           kind: kind,
#           error: inspect(reason),
#           stacktrace: __STACKTRACE__
#         )

#         {:error, reason}
#     end
#   end
# end
