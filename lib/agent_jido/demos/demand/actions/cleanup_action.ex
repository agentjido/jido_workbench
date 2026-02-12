defmodule AgentJido.Demos.Demand.CleanupAction do
  @moduledoc """
  Daily maintenance cleanup that resets accumulated tick count.
  """
  use Jido.Action,
    name: "cleanup",
    description: "Runs daily maintenance cleanup",
    schema: []

  @impl true
  def run(_params, _context) do
    {:ok, %{ticks: 0, last_updated_at: DateTime.utc_now()}}
  end
end
