defmodule AgentJido.Demos.Counter.IncrementAction do
  @moduledoc """
  Increments the counter by a specified amount.
  """
  use Jido.Action,
    name: "increment",
    description: "Increments the counter",
    schema: [
      by: [type: :integer, default: 1, doc: "Amount to increment by"]
    ]

  @impl true
  def run(%{by: amount}, context) do
    current = Map.get(context.state, :count, 0)
    {:ok, %{count: current + amount}}
  end
end
