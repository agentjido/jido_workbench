defmodule AgentJido.Demos.ScheduleDirectiveAgent do
  @moduledoc """
  Demo agent for delayed scheduling, retries, and CRON schedules.
  """

  alias AgentJido.Demos.ScheduleDirective.{
    StartTimerAction,
    HandleTickAction,
    StartRetryAction,
    HandleRetryAction,
    HandleCronTickAction
  }

  use Jido.Agent,
    name: "schedule_directive_agent",
    description: "Demonstrates schedule directives plus CRON schedules",
    schema: [
      status: [type: :atom, default: :idle],
      tick_count: [type: :integer, default: 0],
      attempts: [type: :integer, default: 0],
      max_attempts: [type: :integer, default: 3],
      retry_delay_ms: [type: :integer, default: 80],
      cron_ticks: [type: :integer, default: 0],
      last_timer_id: [type: :string, default: ""],
      last_cron_at: [type: :any, default: nil],
      last_event: [type: :string, default: ""]
    ],
    schedules: [
      {"*/1 * * * *", "cron.tick", job_id: :cron_minute},
      {"0 * * * *", "cron.hourly", job_id: :cron_hourly}
    ],
    signal_routes: [
      {"start_timer", StartTimerAction},
      {"timer.tick", HandleTickAction},
      {"start_retry", StartRetryAction},
      {"retry.attempt", HandleRetryAction},
      {"cron.tick", HandleCronTickAction},
      {"cron.hourly", HandleCronTickAction}
    ]

  @doc false
  @spec plugin_specs() :: nonempty_list(Jido.Plugin.Spec.t())
  def plugin_specs, do: super()

  @doc false
  @spec plugin_schedules() :: nonempty_list(Jido.Plugin.Schedules.schedule_spec())
  def plugin_schedules, do: super()
end
