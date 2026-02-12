defmodule AgentJido.Demos.Demand.HeartbeatAction do
  @moduledoc """
  Scheduled heartbeat tick that applies the same behavior as a manual decay tick.
  """
  use Jido.Action,
    name: "heartbeat_tick",
    description: "Handles scheduled heartbeat ticks",
    schema: []

  alias AgentJido.Demos.Demand.DecayAction

  @impl true
  def run(params, context), do: DecayAction.run(params, context)
end
