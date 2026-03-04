defmodule AgentJido.Demos.ScheduleDirective.HandleCronTickAction do
  @moduledoc """
  Handles CRON-driven tick signals.
  """

  use Jido.Action,
    name: "handle_cron_tick",
    description: "Handles cron.tick and cron.hourly",
    schema: []

  @impl true
  def run(_params, context) do
    cron_ticks = Map.get(context.state, :cron_ticks, 0) + 1
    {:ok, %{cron_ticks: cron_ticks, last_cron_at: DateTime.utc_now(), last_event: "cron.tick"}}
  end
end
