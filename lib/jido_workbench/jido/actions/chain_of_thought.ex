# defmodule JidoWorkbench.Actions.ChainOfThought do
#   require Logger

#   defmodule Schema do
#     use Ecto.Schema
#     use Instructor

#     @llm_doc """
#     A chat response from an AI assistant.

#     ## Fields:
#     - response: The text response to send back to the user
#     - actions: List of actions to take, if any are needed
#       - name: Name of the action to execute
#       - params: Parameters to pass to the action
#     """
#     @primary_key false
#     embedded_schema do
#       field(:response, :string)

#       embeds_many :actions, Action, primary_key: false do
#         field(:name, :string)
#         field(:params, :map)
#       end
#     end
#   end

#   use Jido.Action,
#     name: "chain_of_thought",
#     description: "Generate a response to a chat message with optional actions",
#     schema: [
#       prompt: [type: :string, required: true, doc: "The prompt to use for the response"],
#       message: [type: :string, required: true, doc: "The user's message"],
#       personality: [type: :string, required: true, doc: "The personality of the assistant"],
#       history: [type: {:list, :map}, required: true, doc: "List of previous messages"]
#     ]

#   def run(params, context) do
#     Logger.metadata(action: "chain_of_thought", context: context)

#     # directive = %Jido.Agent.Directive.Enqueue{
#     #   action: JidoWorkbench.Actions.GenerateChatResponse,
#     #   params: params
#     # }

#     {:ok, %{response: "Hello, how are you?"},
#      %Instruction{action: GenerateChatResponse, params: %{last_message: message}}}
#   end

#   # def run(params, context) do
#   #   Logger.metadata(action: "chain_of_thought", context: context)
#   #   Logger.debug("Starting chat response generation", params: inspect(params))

#   #   # Format chat messages
#   #   messages = build_messages(params)

#   #   # Start a supervised task for the LLM call
#   #   task =
#   #     Task.Supervisor.async_nolink(JidoWorkbench.TaskSupervisor, fn ->
#   #       Jido.Workflow.run(
#   #         Jido.AI.Actions.Anthropic.ChatCompletion,
#   #         %{
#   #           model: "claude-3-5-haiku-latest",
#   #           messages: messages,
#   #           response_model: Schema,
#   #           temperature: 0.7,
#   #           max_tokens: 1000
#   #         },
#   #         # Leave 1s buffer for other operations
#   #         timeout: 29_000
#   #       )
#   #     end)

#   #   try do
#   #     # Wait for result with timeout
#   #     case Task.yield(task, 29_000) || Task.shutdown(task, :brutal_kill) do
#   #       {:ok, {:ok, %{result: %Schema{response: response}}}} ->
#   #         {:ok, %{result: response}}

#   #       # {:ok, %{result: %{response: response}}}

#   #       {:ok, {:error, reason}} ->
#   #         Logger.warning("Chat generation failed", error: inspect(reason))
#   #         {:error, reason}

#   #       nil ->
#   #         Logger.warning("Chat generation timed out")
#   #         {:error, :timeout}
#   #     end
#   #   catch
#   #     kind, reason ->
#   #       Logger.warning("Unexpected error in chat generation",
#   #         kind: kind,
#   #         error: inspect(reason),
#   #         stacktrace: __STACKTRACE__
#   #       )

#   #       {:error, reason}
#   #   end
#   # end

#   # Private Helpers

#   defp build_messages(params) do
#     history_messages =
#       Enum.map(params.history, fn msg ->
#         %{
#           role: msg.role,
#           content: msg.content
#         }
#       end)

#     [
#       %{role: "system", content: params.prompt}
#     ] ++
#       history_messages ++
#       [
#         %{
#           role: "user",
#           content: params.message
#         }
#       ]
#   end
# end
