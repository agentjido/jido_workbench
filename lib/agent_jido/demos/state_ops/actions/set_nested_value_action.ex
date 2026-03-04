defmodule AgentJido.Demos.StateOps.SetNestedValueAction do
  @moduledoc """
  Sets a nested value using `StateOp.SetPath`.
  """

  alias Jido.Agent.StateOp

  use Jido.Action,
    name: "set_nested_value",
    description: "Sets nested value by path",
    schema: [
      path: [type: {:list, :atom}, required: true],
      value: [type: :any, required: true]
    ]

  @impl true
  def run(%{path: path, value: value}, _context) do
    {:ok, %{}, %StateOp.SetPath{path: path, value: value}}
  end
end
