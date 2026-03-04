defmodule AgentJido.Demos.ScheduleDirective.HandleTickAction do
  @moduledoc """
  Handles a delayed timer tick.
  """

  use Jido.Action,
    name: "handle_tick",
    description: "Handles timer.tick",
    schema: [
      timer_id: [type: :string, required: true]
    ]

  @impl true
  def run(%{timer_id: timer_id}, context) do
    tick_count = Map.get(context.state, :tick_count, 0) + 1
    {:ok, %{status: :ticked, tick_count: tick_count, last_event: "timer.tick:#{timer_id}"}}
  end
end
