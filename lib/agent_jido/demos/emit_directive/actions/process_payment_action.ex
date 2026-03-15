defmodule AgentJido.Demos.EmitDirective.ProcessPaymentAction do
  @moduledoc """
  Marks an order payment as successful and emits `payment.processed`.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "process_payment",
    description: "Processes payment and emits payment.processed",
    schema: [
      order_id: [type: :string, required: true],
      payment_method: [type: :string, default: "card"]
    ]

  @impl true
  def run(%{order_id: order_id, payment_method: payment_method}, _context) do
    signal =
      Signal.new!(
        "payment.processed",
        %{order_id: order_id, method: payment_method, status: :success},
        source: "/emit"
      )

    last_payment = %{order_id: order_id, method: payment_method, status: :success}

    {:ok, %{last_payment: last_payment}, %Directive.Emit{signal: signal}}
  end
end
