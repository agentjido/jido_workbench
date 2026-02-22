defmodule Mix.Tasks.Analytics.Prune do
  @moduledoc """
  Prunes first-party analytics and query logs older than the retention window.

      mix analytics.prune
      mix analytics.prune --days 90
  """

  use Mix.Task

  alias AgentJido.Analytics

  @shortdoc "Prunes stale analytics/query log rows"

  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    days = parse_days(args)
    result = Analytics.prune_older_than(days)

    Mix.shell().info("Analytics prune complete")
    Mix.shell().info("Cutoff (UTC): #{result.cutoff}")
    Mix.shell().info("Deleted analytics events: #{result.deleted_events}")
    Mix.shell().info("Deleted query logs: #{result.deleted_query_logs}")
  end

  defp parse_days(args) do
    {opts, _argv, _invalid} = OptionParser.parse(args, strict: [days: :integer])

    case Keyword.get(opts, :days, 180) do
      days when is_integer(days) and days > 0 -> days
      _ -> 180
    end
  end
end
