defmodule JidoWorkbench.AgentJido do
  alias Jido.Actions.Directives.{EnqueueAction, RegisterAction}
  alias JidoWorkbench.Actions.GenerateChatResponse

  use Jido.Agent,
    name: "AgentJido",
    description: "Agent Jido",
    actions: [GenerateChatResponse, EnqueueAction, RegisterAction]
end
