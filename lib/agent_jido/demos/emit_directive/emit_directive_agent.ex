defmodule AgentJido.Demos.EmitDirectiveAgent do
  @moduledoc """
  Demo agent for `Directive.Emit` patterns.
  """

  alias AgentJido.Demos.EmitDirective.{
    CreateOrderAction,
    MultiEmitAction,
    ProcessPaymentAction
  }

  use Jido.Agent,
    name: "emit_directive_agent",
    description: "Shows state updates alongside emitted domain events",
    schema: [
      orders: [type: {:list, :map}, default: []],
      last_order_id: [type: :string, default: ""],
      last_payment: [type: :map, default: %{}],
      emitted_count: [type: :integer, default: 0]
    ],
    signal_routes: [
      {"create_order", CreateOrderAction},
      {"process_payment", ProcessPaymentAction},
      {"multi_emit", MultiEmitAction}
    ]

  @doc false
  @spec plugin_specs() :: nonempty_list(Jido.Plugin.Spec.t())
  def plugin_specs, do: super()
end
