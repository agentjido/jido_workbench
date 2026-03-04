defmodule AgentJido.Demos.StateOps.ReplaceAllAction do
  @moduledoc """
  Replaces the full state using `StateOp.ReplaceState`.
  """

  alias Jido.Agent.StateOp

  use Jido.Action,
    name: "replace_all",
    description: "Replaces full state",
    schema: [
      new_state: [type: :map, required: true]
    ]

  @impl true
  def run(%{new_state: new_state}, _context) do
    {:ok, %{}, %StateOp.ReplaceState{state: new_state}}
  end
end
