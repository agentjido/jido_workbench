defmodule AgentJido.ContentOps.Actions.SelectWork do
  @moduledoc """
  Selects work items from the content plan backlog.

  Stub implementation: returns a single synthetic work order in weekly/monthly
  modes, empty list for hourly/nightly (maintenance-only modes).
  """
  use Jido.Action,
    name: "contentops_select_work",
    description: "Selects work items from the content backlog",
    schema: [
      run_id: [type: :string, required: true, doc: "Current run identifier"],
      mode: [type: :any, required: true, doc: "Run cadence mode"],
      started_at: [type: :any, doc: "Run start timestamp"]
    ]

  @impl true
  def run(%{run_id: run_id, mode: mode} = params, _context) do
    work_orders = select_for_mode(run_id, mode)

    {:ok, %{run_id: run_id, mode: mode, started_at: params[:started_at], work_orders: work_orders}}
  end

  defp select_for_mode(run_id, mode) when mode in [:weekly, :monthly] do
    [
      %{
        id: "wo_" <> Base.encode16(:crypto.strong_rand_bytes(4), case: :lower),
        run_id: run_id,
        kind: :docs,
        slug: "docs/spike-#{run_id}",
        priority_score: 0.85,
        source: :stub
      }
    ]
  end

  defp select_for_mode(_run_id, _mode), do: []
end
