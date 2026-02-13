defmodule AgentJido.ContentOps.Chat.Actions.CreateIssue do
  @moduledoc """
  Mutation tool that creates a GitHub issue for ContentOps.
  """

  use Jido.Action,
    name: "contentops_create_issue",
    description: "Create a GitHub issue in the configured ContentOps repository",
    schema:
      Zoi.object(%{
        title: Zoi.string(description: "Issue title"),
        body: Zoi.string(description: "Issue body") |> Zoi.default(""),
        labels: Zoi.array(Zoi.string()) |> Zoi.default([]),
        related_page: Zoi.string(description: "Optional page id/path reference") |> Zoi.optional(),
        reason: Zoi.string(description: "Optional reason for opening this issue") |> Zoi.optional()
      })

  alias AgentJido.ContentOps.Chat.{OpsService, Policy}

  @impl true
  def run(params, context) do
    actor = Policy.actor_from_tool_context(context)
    request = Map.merge(params, pass_through_context(context))

    case OpsService.create_issue(request, actor) do
      {:ok, result} ->
        {:ok, %{result: result.message, data: result}}

      {:error, :unauthorized} ->
        {:ok, %{result: "You are not authorized to create GitHub issues from chat.", error: :unauthorized}}

      {:error, :mutations_disabled} ->
        {:ok, %{result: "Chat mutation tools are disabled in this environment.", error: :mutations_disabled}}

      {:error, :missing_title} ->
        {:ok, %{result: "Issue title is required.", error: :missing_title}}

      {:error, reason} ->
        {:ok, %{result: "Issue creation failed: #{inspect(reason)}", error: inspect(reason)}}
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
