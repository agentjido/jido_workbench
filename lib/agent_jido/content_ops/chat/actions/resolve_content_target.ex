defmodule AgentJido.ContentOps.Chat.Actions.ResolveContentTarget do
  @moduledoc """
  Read tool for deterministic docs/content target resolution.
  """

  use Jido.Action,
    name: "contentops_resolve_content_target",
    description: "Resolve a docs/content target from id/path/url with fuzzy fallback",
    schema:
      Zoi.object(%{
        page_ref: Zoi.string(description: "Page id/path/url reference")
      })

  alias AgentJido.ContentOps.Chat.ContentResolver

  @impl true
  def run(%{page_ref: page_ref}, _context) do
    case ContentResolver.resolve(page_ref) do
      {:ok, target} ->
        {:ok, %{result: "Resolved target: #{target.id}", target: target}}

      {:ambiguous, candidates} ->
        {:ok, %{result: "Ambiguous target. Choose one candidate id/path.", candidates: candidates}}

      {:error, :not_found} ->
        {:ok, %{result: "No matching target found.", error: :not_found}}

      {:error, :missing_ref} ->
        {:ok, %{result: "page_ref is required.", error: :missing_ref}}
    end
  end
end
