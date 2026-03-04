defmodule AgentJido.Demos.SignalRouting.SetNameAction do
  @moduledoc """
  Sets a human-readable name in agent state.
  """

  use Jido.Action,
    name: "set_name",
    description: "Sets agent name",
    schema: [
      name: [type: :string, required: true, doc: "Name to set on agent state"]
    ]

  @impl true
  @spec run(map(), map()) :: {:ok, map()}
  def run(%{name: name}, _context) do
    {:ok, %{name: name}}
  end
end
