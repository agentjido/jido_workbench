defmodule AgentJido.Demos.DemandTrackerAgent do
  @moduledoc """
  A demand tracker agent demonstrating Jido capabilities:
  - Declarative cron schedules for recurring signals
  - Emit: Domain event publication
  - State updates vs side effects separation
  """
  use Jido.Agent,
    name: "demand_tracker",
    description: "Tracks listing demand with scheduled maintenance",
    schema: [
      listing_id: [type: :string, default: "demo-listing"],
      demand: [type: :integer, default: 50],
      ticks: [type: :integer, default: 0],
      last_updated_at: [type: :any, default: nil]
    ],
    schedules: [
      {"*/5 * * * *", "heartbeat.tick", job_id: :heartbeat},
      {"@daily", "cleanup.run", job_id: :cleanup, timezone: "America/New_York"}
    ]

  alias AgentJido.Demos.Demand.{
    BoostAction,
    CleanupAction,
    CoolAction,
    DecayAction,
    HeartbeatAction
  }

  @impl true
  def signal_routes(_ctx) do
    [
      {"listing.demand.boost", BoostAction},
      {"listing.demand.cool", CoolAction},
      {"listing.demand.tick", DecayAction},
      {"heartbeat.tick", HeartbeatAction},
      {"cleanup.run", CleanupAction}
    ]
  end
end
