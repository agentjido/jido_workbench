defmodule AgentJido.ContentOps.Chat.RouterTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Chat.Router

  defmodule OpsServiceStub do
    def run(mode, actor) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:ran_mode, mode, actor})
      {:ok, %{message: "Started ContentOps #{mode} run."}}
    end
  end

  setup do
    original_chat_cfg = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat)
    original_router_cfg = Application.get_env(:agent_jido, Router)
    original_stub_cfg = Application.get_env(:agent_jido, OpsServiceStub)

    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      bindings: [],
      allowed_telegram_user_ids: ["111"],
      allowed_discord_user_ids: [],
      bot_name: "ContentOps",
      command_prefix: "/ops",
      github_owner: "agentjido",
      github_repo: "agentjido_xyz",
      github_labels_base: ["contentops"],
      github_labels_docs_note: ["docs-note"],
      mutation_tools_enabled: true
    )

    Application.put_env(:agent_jido, OpsServiceStub, pid: self())

    Application.put_env(:agent_jido, Router,
      ops_service: OpsServiceStub,
      qa_fun: fn _pid, _prompt, _opts -> {:ok, "qa"} end
    )

    on_exit(fn ->
      if is_nil(original_chat_cfg) do
        Application.delete_env(:agent_jido, AgentJido.ContentOps.Chat)
      else
        Application.put_env(:agent_jido, AgentJido.ContentOps.Chat, original_chat_cfg)
      end

      if is_nil(original_router_cfg) do
        Application.delete_env(:agent_jido, Router)
      else
        Application.put_env(:agent_jido, Router, original_router_cfg)
      end

      if is_nil(original_stub_cfg) do
        Application.delete_env(:agent_jido, OpsServiceStub)
      else
        Application.put_env(:agent_jido, OpsServiceStub, original_stub_cfg)
      end
    end)

    :ok
  end

  test "parse_command/2 recognizes core commands" do
    assert {:ok, :help} = Router.parse_command("/ops help", "/ops")
    assert {:ok, :status} = Router.parse_command("/ops status", "/ops")
    assert {:ok, :recent_runs} = Router.parse_command("/ops recent-runs", "/ops")
    assert {:ok, :coverage} = Router.parse_command("/ops coverage", "/ops")
    assert {:ok, {:run, :weekly}} = Router.parse_command("/ops run weekly", "/ops")
    assert {:ok, {:issue, "foo bar"}} = Router.parse_command("/ops issue foo bar", "/ops")
    assert {:ok, {:note, "fix docs"}} = Router.parse_command("/ops note fix docs", "/ops")
    assert {:ok, {:ask, "what happened"}} = Router.parse_command("/ops ask what happened", "/ops")
    assert {:error, :unknown} = Router.parse_command("/ops nope", "/ops")
  end

  test "handle_message/2 returns noreply for non-addressed non-command text" do
    message = %{room_id: "r1", content: [%JidoMessaging.Content.Text{text: "hello world"}]}
    context = %{}

    assert :noreply = Router.handle_message(message, context)
  end

  test "allowlisted actor can trigger /ops run" do
    message = %{room_id: "r1", content: [%JidoMessaging.Content.Text{text: "/ops run weekly"}]}

    context = %{
      channel: JidoMessaging.Channels.Telegram,
      participant: %{external_ids: %{telegram: "111"}}
    }

    assert {:reply, "Started ContentOps weekly run."} = Router.handle_message(message, context)
    assert_receive {:ran_mode, :weekly, %{channel: :telegram, external_user_id: "111"}}, 1_000
  end

  test "addressed command can trigger /ops run" do
    message = %{room_id: "r1", content: [%JidoMessaging.Content.Text{text: "@ContentOps /ops run weekly"}]}

    context = %{
      channel: JidoMessaging.Channels.Telegram,
      participant: %{external_ids: %{telegram: "111"}}
    }

    assert {:reply, "Started ContentOps weekly run."} = Router.handle_message(message, context)
    assert_receive {:ran_mode, :weekly, %{channel: :telegram, external_user_id: "111"}}, 1_000
  end

  test "run command forwards actor context to ops service" do
    message = %{room_id: "r1", content: [%JidoMessaging.Content.Text{text: "/ops run weekly"}]}

    context = %{
      channel: JidoMessaging.Channels.Telegram,
      participant: %{external_ids: %{telegram: "999"}}
    }

    assert {:reply, "Started ContentOps weekly run."} = Router.handle_message(message, context)
    assert_receive {:ran_mode, :weekly, %{channel: :telegram, external_user_id: "999"}}, 1_000
  end
end
