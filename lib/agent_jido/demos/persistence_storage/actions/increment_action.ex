defmodule AgentJido.Demos.PersistenceStorage.IncrementAction do
  @moduledoc """
  Increments the demo counter.
  """

  use Jido.Action,
    name: "increment",
    description: "Increments counter",
    schema: [
      amount: [type: :integer, default: 1]
    ]

  @impl true
  def run(%{amount: amount}, context) do
    current = Map.get(context.state, :counter, 0)
    {:ok, %{counter: current + amount, status: :updated}}
  end
end
