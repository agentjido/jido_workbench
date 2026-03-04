defmodule AgentJido.Demos.ScheduleDirective.HandleRetryAction do
  @moduledoc """
  Handles retry attempts and reschedules until max attempts are reached.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "handle_retry",
    description: "Processes retry attempt",
    schema: []

  @impl true
  def run(_params, context) do
    attempts = Map.get(context.state, :attempts, 0) + 1
    max_attempts = Map.get(context.state, :max_attempts, 3)
    retry_delay_ms = Map.get(context.state, :retry_delay_ms, 80)

    if attempts >= max_attempts do
      {:ok, %{status: :completed, attempts: attempts, last_event: "retry.completed"}}
    else
      retry_signal = Signal.new!("retry.attempt", %{}, source: "/schedule")
      schedule = %Directive.Schedule{delay_ms: retry_delay_ms, message: retry_signal}
      {:ok, %{status: :retrying, attempts: attempts, last_event: "retry.attempt"}, schedule}
    end
  end
end
