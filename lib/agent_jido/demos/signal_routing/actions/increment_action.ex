defmodule AgentJido.Demos.SignalRouting.IncrementAction do
  @moduledoc """
  Increments the agent counter by a provided amount.
  """

  use Jido.Action,
    name: "increment",
    description: "Increments the counter",
    schema: [
      amount: [type: :integer, default: 1, doc: "Amount to increment by"]
    ]

  @impl true
  @spec run(map(), map()) :: {:ok, map()}
  def run(%{amount: amount}, context) do
    current = Map.get(context.state, :counter, 0)
    {:ok, %{counter: current + amount}}
  end
end
