defmodule AgentJido.ContentOps.Chat.Actions.AddDocNote do
  @moduledoc """
  Mutation tool for adding documentation notes as issue comments or new issues.
  """

  use Jido.Action,
    name: "contentops_add_doc_note",
    description: "Add a doc note by commenting on an issue or creating a docs-note issue",
    schema:
      Zoi.object(%{
        note: Zoi.string(description: "The documentation note text"),
        page_ref: Zoi.string(description: "Page id/path/url reference"),
        issue_number: Zoi.integer(description: "Optional existing issue number to comment on") |> Zoi.optional(),
        labels: Zoi.array(Zoi.string()) |> Zoi.default([])
      })

  alias AgentJido.ContentOps.Chat.{OpsService, Policy}

  @impl true
  def run(params, context) do
    actor = Policy.actor_from_tool_context(context)
    request = Map.merge(params, pass_through_context(context))

    case OpsService.add_doc_note(request, actor) do
      {:ok, %{status: :needs_clarification} = result} ->
        {:ok, %{result: result.message, data: result}}

      {:ok, result} ->
        {:ok, %{result: result.message, data: result}}

      {:error, :unauthorized} ->
        {:ok, %{result: "You are not authorized to add documentation notes from chat.", error: :unauthorized}}

      {:error, :mutations_disabled} ->
        {:ok, %{result: "Chat mutation tools are disabled in this environment.", error: :mutations_disabled}}

      {:error, :invalid_note_request} ->
        {:ok,
         %{
           result: "Doc note requests require both `note` and `page_ref`.",
           error: :invalid_note_request
         }}

      {:error, :target_not_found} ->
        {:ok, %{result: "Could not resolve the target page. Provide an exact id/path.", error: :target_not_found}}

      {:error, reason} ->
        {:ok, %{result: "Doc note request failed: #{inspect(reason)}", error: inspect(reason)}}
    end
  end

  defp pass_through_context(context) do
    %{
      github_owner: context[:github_owner],
      github_repo: context[:github_repo],
      github_client: context[:github_client],
      github_api: context[:github_api]
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
