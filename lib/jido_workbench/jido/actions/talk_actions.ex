defmodule JidoWorkbench.Jido.Actions.Say do
  require Logger

  use Jido.Action,
    name: "say",
    description: "Make an agent say something",
    schema: [
      message: [type: :string, required: true, doc: "The message to say"]
    ]

  def run(params, _context) do
    Logger.metadata(action: "say")

    # Get the message from params
    message = params.message

    # Return success with the message
    {:ok, %{message: message}}
  end
end
