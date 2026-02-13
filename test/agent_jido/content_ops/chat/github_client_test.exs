defmodule AgentJido.ContentOps.Chat.GithubClientTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Chat.GithubClient

  defmodule APIStub do
    def issues_create(_client, owner, repo, payload) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:issues_create, owner, repo, payload})
      {201, %{"number" => 42, "title" => payload["title"], "html_url" => "https://example.test/issues/42"}, []}
    end

    def issue_comments_create(_client, owner, repo, number, payload) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:issue_comments_create, owner, repo, number, payload})
      {201, %{"html_url" => "https://example.test/issues/#{number}#issuecomment-1"}, []}
    end
  end

  setup do
    original_chat_cfg = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat)
    original_stub_cfg = Application.get_env(:agent_jido, APIStub)

    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      bindings: [],
      allowed_telegram_user_ids: [],
      allowed_discord_user_ids: [],
      bot_name: "ContentOps",
      command_prefix: "/ops",
      github_owner: "agentjido",
      github_repo: "agentjido_xyz"
    )

    Application.put_env(:agent_jido, APIStub, pid: self())

    on_exit(fn ->
      if is_nil(original_chat_cfg) do
        Application.delete_env(:agent_jido, AgentJido.ContentOps.Chat)
      else
        Application.put_env(:agent_jido, AgentJido.ContentOps.Chat, original_chat_cfg)
      end

      if is_nil(original_stub_cfg) do
        Application.delete_env(:agent_jido, APIStub)
      else
        Application.put_env(:agent_jido, APIStub, original_stub_cfg)
      end
    end)

    :ok
  end

  test "create_issue/2 strips nil/empty fields and returns normalized result" do
    context = %{github_client: :fake, github_api: APIStub}

    assert {:ok, result} =
             GithubClient.create_issue(
               %{
                 title: "Test title",
                 body: "",
                 labels: ["contentops", "", "chatops"]
               },
               context
             )

    assert result.number == 42
    assert result.url =~ "/issues/42"

    assert_receive {:issues_create, "agentjido", "agentjido_xyz", payload}
    assert payload["title"] == "Test title"
    assert payload["labels"] == ["contentops", "chatops"]
    refute Map.has_key?(payload, "body")
  end

  test "create_issue_comment/3 posts to expected issue number" do
    context = %{github_client: :fake, github_api: APIStub}

    assert {:ok, result} = GithubClient.create_issue_comment(123, "Hello note", context)
    assert result.number == 123
    assert result.url =~ "#issuecomment-1"

    assert_receive {:issue_comments_create, "agentjido", "agentjido_xyz", 123, %{"body" => "Hello note"}}
  end
end
