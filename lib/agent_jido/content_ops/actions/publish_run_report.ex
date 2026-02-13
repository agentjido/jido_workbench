defmodule AgentJido.ContentOps.Actions.PublishRunReport do
  @moduledoc """
  Publishes a run completion report and broadcasts via PubSub.

  Emits the `contentops.run.completed` signal shape and broadcasts
  to the `contentops:runs` PubSub topic for LiveView consumption.
  """
  use Jido.Action,
    name: "contentops_publish_run_report",
    description: "Publishes run completion report via PubSub",
    schema: [
      run_id: [type: :string, required: true, doc: "Current run identifier"],
      mode: [type: :any, required: true, doc: "Run cadence mode"],
      change_request_count: [type: :integer, default: 0, doc: "Number of change requests produced"],
      delivered_count: [type: :integer, default: 0, doc: "Number of deliveries completed"],
      started_at: [type: :any, default: nil, doc: "Run start timestamp"]
    ]

  @impl true
  def run(params, _context) do
    report = %{
      type: "contentops.run.completed",
      run_id: params.run_id,
      mode: params.mode,
      stats: %{
        change_requests: params.change_request_count,
        delivered: params.delivered_count
      },
      started_at: params.started_at,
      completed_at: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(
      AgentJido.PubSub,
      "contentops:runs",
      {:contentops_run_completed, report}
    )

    {:ok, report}
  end
end
