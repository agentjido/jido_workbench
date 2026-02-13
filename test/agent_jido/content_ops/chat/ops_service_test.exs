defmodule AgentJido.ContentOps.Chat.OpsServiceTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Chat.OpsService

  defmodule GithubClientStub do
    def create_issue(request, _context) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:create_issue, request})
      {:ok, %{number: 77, url: "https://example.test/issues/77", owner: "agentjido", repo: "agentjido_xyz"}}
    end

    def create_issue_comment(number, body, _context) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:create_issue_comment, number, body})
      {:ok, %{number: number, url: "https://example.test/issues/#{number}#issuecomment-1"}}
    end
  end

  defmodule ResolverStub do
    def resolve("ambiguous") do
      {:ambiguous,
       [
         %{id: "docs/a", type: :page, path: "/docs/a", title: "A", score: 0.9},
         %{id: "docs/b", type: :page, path: "/docs/b", title: "B", score: 0.88}
       ]}
    end

    def resolve(_ref) do
      {:ok, %{id: "docs/getting-started", type: :page, path: "/docs/getting-started", title: "Getting Started", slug: "getting-started"}}
    end
  end

  defmodule RetrieverStub do
    def fetch(_query, _opts) do
      {:ok, [%{snippet: "snippet one"}, %{snippet: "snippet two"}]}
    end
  end

  setup do
    original_chat_cfg = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat)
    original_service_cfg = Application.get_env(:agent_jido, OpsService)
    original_gh_stub = Application.get_env(:agent_jido, GithubClientStub)

    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      mutation_tools_enabled: true,
      bindings: [],
      allowed_telegram_user_ids: ["111"],
      allowed_discord_user_ids: [],
      bot_name: "ContentOps",
      command_prefix: "/ops",
      github_owner: "agentjido",
      github_repo: "agentjido_xyz",
      github_labels_base: ["contentops", "chatops"],
      github_labels_docs_note: ["docs-note"]
    )

    Application.put_env(:agent_jido, OpsService,
      github_client: GithubClientStub,
      resolver: ResolverStub,
      retriever: RetrieverStub,
      run_fun: fn mode ->
        send(self(), {:run_called, mode})
        %{status: :completed}
      end
    )

    Application.put_env(:agent_jido, GithubClientStub, pid: self())

    on_exit(fn ->
      if is_nil(original_chat_cfg) do
        Application.delete_env(:agent_jido, AgentJido.ContentOps.Chat)
      else
        Application.put_env(:agent_jido, AgentJido.ContentOps.Chat, original_chat_cfg)
      end

      if is_nil(original_service_cfg) do
        Application.delete_env(:agent_jido, OpsService)
      else
        Application.put_env(:agent_jido, OpsService, original_service_cfg)
      end

      if is_nil(original_gh_stub) do
        Application.delete_env(:agent_jido, GithubClientStub)
      else
        Application.put_env(:agent_jido, GithubClientStub, original_gh_stub)
      end
    end)

    :ok
  end

  test "run/2 allows allowlisted actor and starts async run" do
    actor = %{channel: :telegram, external_user_id: "111"}
    assert {:ok, %{action: :run_started}} = OpsService.run(:weekly, actor)
  end

  test "run/2 denies non-allowlisted actor" do
    actor = %{channel: :telegram, external_user_id: "999"}
    assert {:error, :unauthorized} = OpsService.run(:weekly, actor)
  end

  test "create_issue/2 creates issue with base and subtype labels" do
    actor = %{channel: :telegram, external_user_id: "111"}

    assert {:ok, %{action: :issue_created, number: 77}} =
             OpsService.create_issue(%{title: "Need docs cleanup"}, actor)

    assert_receive {:create_issue, request}
    assert request.title == "Need docs cleanup"
    assert "contentops" in request.labels
    assert "chatops" in request.labels
    assert "ops-issue" in request.labels
  end

  test "create_issue/2 denies non-allowlisted actor" do
    actor = %{channel: :telegram, external_user_id: "999"}

    assert {:error, :unauthorized} =
             OpsService.create_issue(%{title: "Should not be created"}, actor)
  end

  test "add_doc_note/2 comments on existing issue when issue_number is provided" do
    actor = %{channel: :telegram, external_user_id: "111"}

    assert {:ok, %{action: :issue_commented, number: 123}} =
             OpsService.add_doc_note(%{note: "fix this section", page_ref: "docs/getting-started", issue_number: 123}, actor)

    assert_receive {:create_issue_comment, 123, body}
    assert body =~ "Doc note submitted"
  end

  test "add_doc_note/2 creates docs-note issue when issue number is absent" do
    actor = %{channel: :telegram, external_user_id: "111"}

    assert {:ok, %{action: :issue_created, number: 77}} =
             OpsService.add_doc_note(%{note: "add example", page_ref: "docs/getting-started"}, actor)

    assert_receive {:create_issue, request}
    assert request.title =~ "Docs note:"
    assert "docs-note" in request.labels
  end

  test "add_doc_note/2 returns clarification when target is ambiguous" do
    actor = %{channel: :telegram, external_user_id: "111"}

    assert {:ok, %{status: :needs_clarification, candidates: candidates}} =
             OpsService.add_doc_note(%{note: "which one?", page_ref: "ambiguous"}, actor)

    assert length(candidates) >= 2
    refute_receive {:create_issue, _}
    refute_receive {:create_issue_comment, _, _}
  end
end
