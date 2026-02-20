defmodule AgentJidoWeb.BlogHTML do
  use AgentJidoWeb, :html

  import AgentJidoWeb.Jido.MarketingLayouts, only: [marketing_layout: 1]

  embed_templates "blog_html/*"

  def format_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end

  def format_rfc822_date(date) do
    date
    |> to_datetime_utc()
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S GMT")
  end

  def preview(body) do
    # Get first 150 characters of post body, ending at word boundary
    body
    |> String.slice(0, 150)
    |> String.split(~r/\s/)
    |> Enum.drop(-1)
    |> Enum.join(" ")
    |> Kernel.<>("...")
  end

  defp to_datetime_utc(%DateTime{} = date_time), do: DateTime.shift_zone!(date_time, "Etc/UTC")

  defp to_datetime_utc(%NaiveDateTime{} = naive_date_time),
    do: DateTime.from_naive!(naive_date_time, "Etc/UTC")

  defp to_datetime_utc(%Date{} = date),
    do: DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
end
