defmodule AgentJido.ContentOps.Chat.ContextRetriever do
  @moduledoc """
  Retrieves Arcana snippets to enrich GitHub issue/note context.
  """

  @default_limit 3
  @default_collection "site_docs"
  @fallback_collections ["site_docs", "site_blog", "site_ecosystem"]

  @doc """
  Fetch snippets for a query.
  """
  @spec fetch(String.t(), keyword()) :: {:ok, [map()]} | {:error, term()}
  def fetch(query, opts \\ [])

  def fetch(query, opts) when is_binary(query) do
    query = String.trim(query)
    limit = Keyword.get(opts, :limit, @default_limit)
    repo = Keyword.get(opts, :repo, AgentJido.Repo)
    preferred_collection = Keyword.get(opts, :preferred_collection, @default_collection)

    if query == "" do
      {:ok, []}
    else
      with {:ok, snippets} <- search(query, repo, preferred_collection, limit),
           {:ok, fallback} <- maybe_fallback(query, repo, snippets, limit) do
        {:ok, fallback}
      end
    end
  end

  def fetch(_query, _opts), do: {:ok, []}

  defp maybe_fallback(query, repo, [], limit) do
    case Arcana.search(query, repo: repo, collections: @fallback_collections, limit: limit, mode: :hybrid) do
      {:ok, results} -> {:ok, to_snippets(results, limit)}
      {:error, reason} -> {:error, reason}
    end
  rescue
    _ -> {:ok, []}
  end

  defp maybe_fallback(_query, _repo, snippets, _limit), do: {:ok, snippets}

  defp search(query, repo, collection, limit) do
    case Arcana.search(query, repo: repo, collection: collection, limit: limit, mode: :hybrid) do
      {:ok, results} -> {:ok, to_snippets(results, limit)}
      {:error, reason} -> {:error, reason}
    end
  rescue
    _ -> {:ok, []}
  end

  defp to_snippets(results, limit) when is_list(results) do
    results
    |> Enum.take(limit)
    |> Enum.map(fn result ->
      %{
        score: result[:score],
        document_id: result[:document_id],
        chunk_id: result[:id],
        snippet: trim_snippet(result[:text] || "", 320)
      }
    end)
  end

  defp to_snippets(_other, _limit), do: []

  defp trim_snippet(text, max_len) when is_binary(text) do
    text = String.trim(text)

    if String.length(text) <= max_len do
      text
    else
      String.slice(text, 0, max_len) <> "..."
    end
  end

  defp trim_snippet(_other, _max_len), do: ""
end
