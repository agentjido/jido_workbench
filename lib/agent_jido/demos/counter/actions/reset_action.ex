defmodule AgentJido.Demos.Counter.ResetAction do
  @moduledoc """
  Resets the counter to zero.
  """
  use Jido.Action,
    name: "reset",
    description: "Resets the counter to zero",
    schema: []

  @impl true
  def run(_params, _context) do
    {:ok, %{count: 0}}
  end
end
