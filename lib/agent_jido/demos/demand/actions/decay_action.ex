defmodule AgentJido.Demos.Demand.DecayAction do
  @moduledoc """
  Decays demand toward zero by a fixed amount.
  Emits a domain event when demand changes.
  """
  use Jido.Action,
    name: "decay",
    description: "Decays demand toward zero",
    schema: []

  alias Jido.Agent.Directive
  alias Jido.Signal

  @decay_amount 2

  @impl true
  def run(_params, context) do
    current_demand = Map.get(context.state, :demand, 50)
    listing_id = Map.get(context.state, :listing_id, "demo-listing")
    ticks = Map.get(context.state, :ticks, 0)
    now = DateTime.utc_now()

    new_demand = max(current_demand - @decay_amount, 0)

    state = %{
      demand: new_demand,
      ticks: ticks + 1,
      last_updated_at: now
    }

    directives = []

    # Emit domain event if demand changed
    directives =
      if current_demand != new_demand do
        emit_signal =
          Signal.new!(
            "listing.demand.changed",
            %{
              listing_id: listing_id,
              previous: current_demand,
              current: new_demand,
              delta: new_demand - current_demand,
              reason: :decay
            },
            source: "/demo/demand-tracker"
          )

        [Directive.emit(emit_signal) | directives]
      else
        directives
      end

    {:ok, state, directives}
  end
end
