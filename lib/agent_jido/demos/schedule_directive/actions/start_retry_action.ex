defmodule AgentJido.Demos.ScheduleDirective.StartRetryAction do
  @moduledoc """
  Starts bounded retry scheduling.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "start_retry",
    description: "Starts bounded retry loop",
    schema: [
      max_attempts: [type: :integer, default: 3],
      retry_delay_ms: [type: :integer, default: 80]
    ]

  @impl true
  def run(%{max_attempts: max_attempts, retry_delay_ms: retry_delay_ms}, _context) do
    retry_signal = Signal.new!("retry.attempt", %{}, source: "/schedule")
    schedule = %Directive.Schedule{delay_ms: retry_delay_ms, message: retry_signal}

    {:ok,
     %{
       status: :retrying,
       attempts: 0,
       max_attempts: max_attempts,
       retry_delay_ms: retry_delay_ms,
       last_event: "retry.started"
     }, schedule}
  end
end
