defmodule AgentJido.Demos.StateOps.ClearTempDataAction do
  @moduledoc """
  Removes top-level temporary keys using `StateOp.DeleteKeys`.
  """

  alias Jido.Agent.StateOp

  use Jido.Action,
    name: "clear_temp_data",
    description: "Clears temp/cache keys",
    schema: []

  @impl true
  def run(_params, _context) do
    {:ok, %{}, %StateOp.DeleteKeys{keys: [:temp, :cache]}}
  end
end
