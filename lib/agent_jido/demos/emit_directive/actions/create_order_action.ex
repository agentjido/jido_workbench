defmodule AgentJido.Demos.EmitDirective.CreateOrderAction do
  @moduledoc """
  Creates an order and emits an `order.created` domain event.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "create_order",
    description: "Creates an order and emits order.created",
    schema: [
      order_id: [type: :string, required: true],
      total: [type: :integer, required: true]
    ]

  @impl true
  def run(%{order_id: order_id, total: total}, context) do
    orders = Map.get(context.state, :orders, [])

    order = %{
      id: order_id,
      total: total,
      status: :pending,
      created_at: DateTime.utc_now()
    }

    signal = Signal.new!("order.created", %{order_id: order_id, total: total}, source: "/emit")

    {:ok, %{orders: [order | orders], last_order_id: order_id}, %Directive.Emit{signal: signal}}
  end
end
