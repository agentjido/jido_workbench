defmodule AgentJido.Demos.SignalRoutingAgent do
  @moduledoc """
  Agent showcasing signal-based routing to distinct actions.
  """

  alias AgentJido.Demos.SignalRouting.{
    IncrementAction,
    RecordEventAction,
    SetNameAction
  }

  use Jido.Agent,
    name: "signal_routing_agent",
    description: "Routes incoming signals to dedicated actions",
    schema: [
      counter: [type: :integer, default: 0],
      name: [type: :string, default: ""],
      events: [type: {:list, :map}, default: []]
    ],
    signal_routes: [
      {"increment", IncrementAction},
      {"set_name", SetNameAction},
      {"record_event", RecordEventAction}
    ]

  @doc false
  @spec plugin_specs() :: nonempty_list(Jido.Plugin.Spec.t())
  def plugin_specs, do: super()
end
