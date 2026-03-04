defmodule AgentJido.Demos.ScheduleDirective.StartTimerAction do
  @moduledoc """
  Starts a one-shot delayed timer via `Directive.Schedule`.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "start_timer",
    description: "Schedules timer.tick after delay",
    schema: [
      delay_ms: [type: :integer, default: 120],
      timer_id: [type: :string, required: true]
    ]

  @impl true
  def run(%{delay_ms: delay_ms, timer_id: timer_id}, _context) do
    tick_signal = Signal.new!("timer.tick", %{timer_id: timer_id}, source: "/schedule")
    schedule = %Directive.Schedule{delay_ms: delay_ms, message: tick_signal}

    {:ok, %{status: :waiting, last_timer_id: timer_id, last_event: "timer.started"}, schedule}
  end
end
