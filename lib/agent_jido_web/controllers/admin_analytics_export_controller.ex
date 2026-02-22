defmodule AgentJidoWeb.AdminAnalyticsExportController do
  @moduledoc """
  CSV exports for admin analytics reports.
  """
  use AgentJidoWeb, :controller

  alias AgentJido.Analytics

  @default_days 30

  @spec gaps(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def gaps(conn, params) do
    days = parse_days(params)

    rows =
      analytics_module().content_gap_rows_for_export(conn.assigns[:current_scope], days, 500)
      |> Enum.map(fn row ->
        [
          row.query,
          row.query_hash,
          row.demand_count,
          row.success_count,
          row.failure_count,
          row.failure_rate,
          row.gap_score
        ]
      end)

    csv =
      to_csv(
        [
          "query",
          "query_hash",
          "demand_count",
          "success_count",
          "failure_count",
          "failure_rate",
          "gap_score"
        ],
        rows
      )

    download_csv(conn, csv, "analytics-gaps-#{days}d.csv")
  end

  @spec feedback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def feedback(conn, params) do
    days = parse_days(params)

    rows =
      analytics_module().feedback_rows_for_export(conn.assigns[:current_scope], days, 500)
      |> Enum.map(fn row ->
        [
          format_datetime(row.inserted_at),
          row.path,
          row.source,
          row.channel,
          row.surface,
          row.feedback_value,
          row.feedback_note,
          row.query_log_id
        ]
      end)

    csv =
      to_csv(
        [
          "inserted_at_utc",
          "path",
          "source",
          "channel",
          "surface",
          "feedback_value",
          "feedback_note",
          "query_log_id"
        ],
        rows
      )

    download_csv(conn, csv, "analytics-feedback-#{days}d.csv")
  end

  defp parse_days(params) do
    case Integer.parse(to_string(Map.get(params, "days", @default_days))) do
      {days, ""} when days > 0 and days <= 365 -> days
      _ -> @default_days
    end
  end

  defp download_csv(conn, csv, filename) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_resp(200, csv)
  end

  defp to_csv(headers, rows) when is_list(headers) and is_list(rows) do
    [headers | rows]
    |> Enum.map(&csv_line/1)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp csv_line(values) do
    values
    |> Enum.map(&csv_escape/1)
    |> Enum.join(",")
  end

  defp csv_escape(nil), do: ""

  defp csv_escape(value) do
    escaped =
      value
      |> to_string()
      |> String.replace("\"", "\"\"")

    ~s("#{escaped}")
  end

  defp format_datetime(%NaiveDateTime{} = datetime), do: Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  defp format_datetime(%DateTime{} = datetime), do: Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  defp format_datetime(_datetime), do: ""

  defp analytics_module do
    Application.get_env(:agent_jido, :analytics_module, Analytics)
  end
end
