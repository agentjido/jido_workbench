defmodule AgentJido.Demos.Demand.CoolAction do
  @moduledoc """
  Decreases demand by a specified amount.
  Emits a domain event via the Emit directive.
  """
  use Jido.Action,
    name: "cool",
    description: "Cools listing demand",
    schema: [
      amount: [type: :integer, default: 10, doc: "Amount to cool demand by"]
    ]

  alias Jido.Agent.Directive
  alias Jido.Signal

  @impl true
  def run(%{amount: amount}, context) do
    current_demand = Map.get(context.state, :demand, 50)
    listing_id = Map.get(context.state, :listing_id, "demo-listing")
    new_demand = max(current_demand - amount, 0)
    now = DateTime.utc_now()

    emit_signal =
      Signal.new!(
        "listing.demand.changed",
        %{
          listing_id: listing_id,
          previous: current_demand,
          current: new_demand,
          delta: -amount,
          reason: :cool
        },
        source: "/demo/demand-tracker"
      )

    {:ok, %{demand: new_demand, last_updated_at: now}, Directive.emit(emit_signal)}
  end
end
