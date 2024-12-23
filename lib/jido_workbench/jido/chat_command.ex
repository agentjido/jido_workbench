defmodule JidoWorkbench.Jido.ChatCommands do
  use Jido.Command

  @impl true
  def commands do
    [
      generate_chat_response: [
        description: "Generate a chat response",
        schema: [
          prompt: [type: :string, required: true, doc: "The prompt to use for the response"],
          message: [type: :string, required: true, doc: "The user's message"],
          personality: [type: :string, required: true, doc: "The personality of the assistant"],
          history: [type: {:list, :map}, required: true, doc: "List of previous messages"],
          available_commands: [
            type: {:list, :map},
            required: true,
            doc: "List of available commands"
          ]
        ]
      ]
    ]
  end

  @impl true
  def handle_command(:generate_chat_response, params, _context) do
    {:ok,
     [
       {JidoWorkbench.Actions.GenerateChatResponse, params.state}
     ]}
  end
end
