defmodule AgentJido.Demos.StateOps.DeleteNestedValueAction do
  @moduledoc """
  Deletes a nested value using `StateOp.DeletePath`.
  """

  alias Jido.Agent.StateOp

  use Jido.Action,
    name: "delete_nested_value",
    description: "Deletes nested value by path",
    schema: [
      path: [type: {:list, :atom}, required: true]
    ]

  @impl true
  def run(%{path: path}, _context) do
    {:ok, %{}, %StateOp.DeletePath{path: path}}
  end
end
