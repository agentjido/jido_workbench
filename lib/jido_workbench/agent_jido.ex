defmodule JidoWorkbench.AgentJido do
  use Jido.Agent,
    name: "AgentJido",
    description: "Agent Jido",
    actions: [JidoWorkbench.Actions.GenerateChatResponse]
end
