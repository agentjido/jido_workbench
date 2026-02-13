defmodule AgentJido.Demos.GithubAgentTest do
  @moduledoc """
  Integration tests for the GithubAgent tools.

  These tests hit the real GitHub API and create/modify real resources.
  Requires GITHUB_TOKEN environment variable.

  Run with: mix test test/agent_jido/demos/github_agent_test.exs --include github_agent
  """
  use ExUnit.Case, async: false

  @moduletag :github_agent
  @owner "agentjido"
  @repo "agentjido_xyz"

  setup do
    token = System.get_env("GITHUB_TOKEN")

    if is_nil(token) or token == "" do
      IO.puts("Skipping: GITHUB_TOKEN not set")
      :skip
    else
      client = Tentacat.Client.new(%{access_token: token})
      context = %{client: client}
      %{client: client, context: context}
    end
  end

  describe "Issues tools" do
    test "creates, finds, and closes an issue", %{client: client, context: context} do
      # Create directly via Tentacat (upstream Issues.Create sends nils that GitHub rejects)
      rand = :rand.uniform(9999)

      {201, issue, _} =
        Tentacat.Issues.create(client, @owner, @repo, %{
          "title" => "[GithubAgent Test] Issue #{rand}",
          "body" => "Automated test. Created: #{DateTime.utc_now()}"
        })

      issue_num = issue["number"]
      assert is_integer(issue_num)
      assert issue["state"] == "open"

      # Find via tool
      {:ok, find_result} =
        Jido.Tools.Github.Issues.Find.run(
          %{owner: @owner, repo: @repo, number: issue_num},
          context
        )

      {200, found, _} = find_result.data
      assert found["number"] == issue_num
      assert found["title"] =~ "#{rand}"

      # Close it
      {200, updated, _} =
        Tentacat.Issues.update(client, @owner, @repo, issue_num, %{"state" => "closed"})

      assert updated["state"] == "closed"
    end

    test "lists issues", %{context: context} do
      {:ok, result} =
        Jido.Tools.Github.Issues.List.run(%{owner: @owner, repo: @repo}, context)

      {200, issues, _} = result.data
      assert is_list(issues)
    end

    test "filters issues by state", %{client: client} do
      # Use Tentacat directly since upstream Issues.Filter sends nil params
      {200, issues, _} =
        Tentacat.Issues.filter(client, @owner, @repo, %{state: "closed"})

      assert is_list(issues)
      Enum.each(issues, fn i -> assert i["state"] == "closed" end)
    end
  end

  describe "Issue Comments tools" do
    test "creates and lists comments on an issue", %{client: client, context: context} do
      # Create an issue
      {201, issue, _} =
        Tentacat.Issues.create(client, @owner, @repo, %{
          "title" => "[GithubAgent Test] Comment Test #{:rand.uniform(9999)}",
          "body" => "Testing comments."
        })

      issue_num = issue["number"]

      # Create comment via tool
      {:ok, comment_result} =
        Jido.Tools.Github.IssueComments.Create.run(
          %{
            owner: @owner,
            repo: @repo,
            number: issue_num,
            body: "🤖 Automated comment from GithubAgent test."
          },
          context
        )

      {201, comment, _} = comment_result.data
      assert comment["body"] =~ "Automated comment"

      # List comments via tool
      {:ok, list_result} =
        Jido.Tools.Github.IssueComments.List.run(
          %{owner: @owner, repo: @repo, number: issue_num},
          context
        )

      {200, comments, _} = list_result.data
      assert is_list(comments)
      assert length(comments) >= 1

      # Clean up
      Tentacat.Issues.update(client, @owner, @repo, issue_num, %{"state" => "closed"})
    end
  end

  describe "Pull Request tools" do
    test "lists pull requests", %{context: context} do
      {:ok, result} =
        Jido.Tools.Github.Pulls.List.run(%{owner: @owner, repo: @repo}, context)

      {200, prs, _} = result.data
      assert is_list(prs)
    end
  end

  describe "Webhook tools" do
    test "lists webhooks (may 404 without admin access)", %{context: context} do
      {:ok, result} =
        Jido.Tools.Github.Webhooks.List.run(%{owner: @owner, repo: @repo}, context)

      case result.data do
        {200, hooks, _} ->
          assert is_list(hooks)

        {404, _, _} ->
          IO.puts("  Webhooks returned 404 - token may lack admin scope on this repo")
          assert true
      end
    end
  end

  describe "GithubAgent ReAct" do
    @describetag :slow
    @tag timeout: 120_000
    test "agent can list issues via natural language" do
      {:ok, pid} =
        Jido.AgentServer.start_link(
          agent: AgentJido.Demos.GithubAgent,
          jido: AgentJido.Jido
        )

      {:ok, result} =
        AgentJido.Demos.GithubAgent.ask_sync(
          pid,
          "List all open issues on #{@owner}/#{@repo}. Just give me the count and the issue numbers/titles.",
          timeout: 90_000
        )

      assert is_binary(result)
      assert String.length(result) > 0
      IO.puts("\n--- Agent Response ---\n#{result}")
    end
  end
end
