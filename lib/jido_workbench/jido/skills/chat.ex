# defmodule JidoWorkbench.Skills.Chat do
#   use Jido.Skill,
#     name: "chat",
#     description: "Chat with the agent",
#     category: "chat",
#     tags: ["chat", "ai", "agent"],
#     vsn: "1.0.0",
#     schema_key: :chat,
#     signals: %{
#       input: ["chat.message.generate_response"],
#       output: ["chat.message.response_generated"]
#     }

#   require Logger

#   def initial_state do
#     %{
#       messages: []
#     }
#   end

#   def router,
#     do: [
#       {"chat.message.generate_response",
#        %Instruction{action: GenerateChatResponse, opts: [timeout: 20_000]}}
#     ]

#   def handle_result(
#         {:ok, %{chat_response: response}},
#         "chat.message.response_generated"
#       ) do
#     [
#       Signal.new(%{
#         type: "chat.message.sent",
#         data: %{message: response}
#       })
#     ]
#   end

#   def handle_result(unexpected, type) do
#     Logger.error("Unexpected result: #{inspect(unexpected)} for type: #{inspect(type)}")
#     []
#   end
# end
