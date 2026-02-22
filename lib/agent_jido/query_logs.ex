defmodule AgentJido.QueryLogs do
  @moduledoc """
  Query tracking context for Ask AI and search activity.
  """
  import Ecto.Query, warn: false

  alias AgentJido.QueryLogs.QueryLog
  alias AgentJido.Repo

  @default_days 7
  @default_recent_limit 100
  @default_top_limit 10

  @type summary :: %{
          days: pos_integer(),
          since: NaiveDateTime.t(),
          total: non_neg_integer(),
          ask_ai: non_neg_integer(),
          search: non_neg_integer(),
          success: non_neg_integer(),
          no_results: non_neg_integer(),
          failed: non_neg_integer()
        }

  @type top_query :: %{query: String.t(), count: non_neg_integer()}

  @doc """
  Creates a query log entry.
  """
  @spec create_query_log(map() | keyword()) :: {:ok, QueryLog.t()} | {:error, Ecto.Changeset.t()}
  def create_query_log(attrs) do
    attrs = normalize_attrs(attrs)

    %QueryLog{}
    |> QueryLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Best-effort query logging that never raises and returns the inserted record or `nil`.
  """
  @spec track_query_safe(map() | keyword()) :: QueryLog.t() | nil
  def track_query_safe(attrs) do
    case create_query_log(attrs) do
      {:ok, query_log} -> query_log
      {:error, _changeset} -> nil
    end
  rescue
    _ -> nil
  catch
    _, _ -> nil
  end

  @doc """
  Best-effort finalization update for a query log entry.
  """
  @spec finalize_query_safe(Ecto.UUID.t() | nil, map() | keyword()) :: :ok
  def finalize_query_safe(nil, _attrs), do: :ok

  def finalize_query_safe(query_log_id, attrs) when is_binary(query_log_id) do
    attrs = normalize_attrs(attrs)

    case Repo.get(QueryLog, query_log_id) do
      nil ->
        :ok

      %QueryLog{} = query_log ->
        query_log
        |> QueryLog.finalize_changeset(attrs)
        |> Repo.update()

        :ok
    end
  rescue
    _ -> :ok
  catch
    _, _ -> :ok
  end

  @doc """
  Returns recent query logs ordered by latest first.
  """
  @spec list_recent_query_logs(pos_integer()) :: [QueryLog.t()]
  def list_recent_query_logs(limit \\ @default_recent_limit) when is_integer(limit) and limit > 0 do
    QueryLog
    |> order_by([q], desc: q.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Returns top repeated queries for a lookback window.
  """
  @spec list_top_queries(pos_integer(), pos_integer()) :: [top_query()]
  def list_top_queries(days \\ @default_days, limit \\ @default_top_limit)
      when is_integer(days) and days > 0 and is_integer(limit) and limit > 0 do
    since = since_naive(days)

    from(q in QueryLog,
      where: q.inserted_at >= ^since,
      group_by: q.query,
      select: %{query: q.query, count: count(q.id)},
      order_by: [desc: count(q.id), asc: q.query],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns aggregate query volume for a lookback window.
  """
  @spec query_volume_summary(pos_integer()) :: summary()
  def query_volume_summary(days \\ @default_days) when is_integer(days) and days > 0 do
    since = since_naive(days)
    base = from(q in QueryLog, where: q.inserted_at >= ^since)

    %{
      days: days,
      since: since,
      total: Repo.aggregate(base, :count, :id),
      ask_ai: count_for(base, source: "ask_ai"),
      search: count_for(base, source: "search"),
      success: count_for(base, status: "success"),
      no_results: count_for(base, status: "no_results"),
      failed: count_for(base, status_in: ["error", "challenge"])
    }
  end

  @doc """
  Best-effort dashboard snapshot used by admin UI.
  """
  @spec dashboard_snapshot(pos_integer(), pos_integer(), pos_integer()) :: %{
          summary: summary(),
          top_queries: [top_query()],
          recent_queries: [QueryLog.t()],
          unavailable?: boolean()
        }
  def dashboard_snapshot(days \\ @default_days, recent_limit \\ @default_recent_limit, top_limit \\ @default_top_limit)
      when is_integer(days) and days > 0 and is_integer(recent_limit) and recent_limit > 0 and
             is_integer(top_limit) and top_limit > 0 do
    %{
      summary: query_volume_summary(days),
      top_queries: list_top_queries(days, top_limit),
      recent_queries: list_recent_query_logs(recent_limit),
      unavailable?: false
    }
  rescue
    _ ->
      %{
        summary: empty_summary(days),
        top_queries: [],
        recent_queries: [],
        unavailable?: true
      }
  catch
    _, _ ->
      %{
        summary: empty_summary(days),
        top_queries: [],
        recent_queries: [],
        unavailable?: true
      }
  end

  defp count_for(base_query, filters) when is_list(filters) do
    base_query
    |> apply_filters(filters)
    |> Repo.aggregate(:count, :id)
  end

  defp apply_filters(query, []), do: query

  defp apply_filters(query, [{:source, source} | rest]) when is_binary(source) do
    query
    |> where([q], q.source == ^source)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:status, status} | rest]) when is_binary(status) do
    query
    |> where([q], q.status == ^status)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:status_in, statuses} | rest]) when is_list(statuses) do
    query
    |> where([q], q.status in ^statuses)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [_unknown | rest]), do: apply_filters(query, rest)

  defp normalize_attrs(attrs) when is_map(attrs), do: attrs
  defp normalize_attrs(attrs) when is_list(attrs), do: Map.new(attrs)
  defp normalize_attrs(_attrs), do: %{}

  defp since_naive(days) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-days * 86_400, :second)
  end

  defp empty_summary(days) do
    %{
      days: days,
      since: since_naive(days),
      total: 0,
      ask_ai: 0,
      search: 0,
      success: 0,
      no_results: 0,
      failed: 0
    }
  end
end
