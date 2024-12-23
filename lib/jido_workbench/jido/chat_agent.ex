defmodule JidoWorkbench.Jido.Agent do
  use Jido.Agent,
    name: "AgentJido",
    description: "Jido agent",
    commands: [JidoWorkbench.Jido.ChatCommands]
end
