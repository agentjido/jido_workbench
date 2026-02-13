defmodule AgentJido.ContentOps.Chat.Actions.FetchContextSnippets do
  @moduledoc """
  Read tool for retrieving Arcana snippets to enrich issue/note workflows.
  """

  use Jido.Action,
    name: "contentops_fetch_context_snippets",
    description: "Fetch relevant Arcana snippets from docs/blog/ecosystem collections",
    schema:
      Zoi.object(%{
        query: Zoi.string(description: "Search query"),
        limit: Zoi.integer(description: "Max snippets") |> Zoi.default(3)
      })

  alias AgentJido.ContentOps.Chat.ContextRetriever

  @impl true
  def run(%{query: query, limit: limit}, _context) do
    case ContextRetriever.fetch(query, limit: limit, preferred_collection: "site_docs") do
      {:ok, snippets} ->
        {:ok, %{result: "Fetched #{length(snippets)} snippets", snippets: snippets}}

      {:error, reason} ->
        {:ok, %{result: "Snippet retrieval failed: #{inspect(reason)}", error: inspect(reason)}}
    end
  end
end
