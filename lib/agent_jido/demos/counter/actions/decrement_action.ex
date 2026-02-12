defmodule AgentJido.Demos.Counter.DecrementAction do
  @moduledoc """
  Decrements the counter by a specified amount.
  """
  use Jido.Action,
    name: "decrement",
    description: "Decrements the counter",
    schema: [
      by: [type: :integer, default: 1, doc: "Amount to decrement by"]
    ]

  @impl true
  def run(%{by: amount}, context) do
    current = Map.get(context.state, :count, 0)
    {:ok, %{count: current - amount}}
  end
end
