defmodule AgentJido.ContentOps.Actions.DeliverySink do
  @moduledoc """
  Records change requests without writing to the filesystem or GitHub.

  Stub replacement for `Delivery.GitHubPRAgent`. Logs what would be delivered
  and returns delivery receipts. Will be replaced by the real PR agent.
  """
  use Jido.Action,
    name: "contentops_delivery_sink",
    description: "Records change requests (stub for GitHub PR delivery)",
    schema: [
      run_id: [type: :string, required: true, doc: "Current run identifier"],
      change_requests: [type: {:list, :map}, default: [], doc: "Change requests to deliver"],
      change_request_count: [type: :integer, default: 0, doc: "Number of change requests"],
      mode: [type: :any, doc: "Run cadence mode"],
      started_at: [type: :any, doc: "Run start timestamp"]
    ]

  require Logger

  @impl true
  def run(%{run_id: run_id, change_requests: change_requests} = params, _context) do
    Enum.each(change_requests, fn cr ->
      Logger.info("[ContentOps.DeliverySink] Would deliver PR for #{length(cr.changes)} change(s) in run #{run_id}")
    end)

    {:ok,
     %{
       run_id: run_id,
       mode: params[:mode],
       started_at: params[:started_at],
       change_request_count: params[:change_request_count] || length(change_requests),
       delivery_receipts: Enum.map(change_requests, &build_receipt(run_id, &1)),
       delivered_count: length(change_requests)
     }}
  end

  defp build_receipt(run_id, change_request) do
    %{
      run_id: run_id,
      slug: change_request[:related_plan_slug],
      status: :recorded,
      pr_url: nil,
      delivered_at: DateTime.utc_now()
    }
  end
end
