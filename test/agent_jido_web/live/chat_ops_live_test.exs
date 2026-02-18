defmodule AgentJidoWeb.ChatOpsLiveTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint AgentJidoWeb.Endpoint

  defmodule PopulatedInventoryStub do
    @moduledoc false

    def fetch_room_inventory do
      {:ok,
       [
         %{
           room_id: "contentops:lobby",
           room_name: "ContentOps Lobby",
           bindings: [
             %{
               channel: :telegram,
               external_room_id: "645038810",
               instance_id: "AgentJido.ContentOps.Chat.TelegramHandler"
             },
             %{
               channel: :discord,
               external_room_id: "1468796189997662487",
               instance_id: "AgentJido.ContentOps.Chat.DiscordHandler"
             }
           ]
         },
         %{
           room_id: "contentops:empty",
           room_name: "Room Without Bindings",
           bindings: []
         },
         %{
           room_id: "contentops:partial",
           room_name: "Room With Partial Binding",
           bindings: [%{channel: :telegram, external_room_id: nil, instance_id: nil}, %{}]
         }
       ]}
    end
  end

  defmodule EmptyInventoryStub do
    @moduledoc false

    def fetch_room_inventory, do: {:ok, []}
  end

  defmodule EmptyMessageTimelineStub do
    @moduledoc false

    def fetch_recent_messages(_opts), do: {:ok, []}
  end

  defmodule PopulatedMessageTimelineStub do
    @moduledoc false

    def fetch_recent_messages(_opts) do
      {:ok,
       [
         %{
           id: "msg-2",
           timestamp: ~U[2026-02-18 14:24:00Z],
           room_id: "contentops:lobby",
           actor: "alice",
           channel: :telegram,
           snippet: "Need status on weekly run."
         },
         %{
           id: "msg-1",
           timestamp: "2026-02-18T14:22:10Z",
           room_id: "contentops:triage",
           actor: "octocat",
           channel: "discord",
           snippet: "Please review issue #123."
         }
       ]}
    end
  end

  defmodule HighVolumeMessageTimelineStub do
    @moduledoc false

    def fetch_recent_messages(_opts) do
      base = ~U[2026-02-18 00:00:00Z]

      {:ok,
       Enum.map(60..1//-1, fn idx ->
         %{
           id: "bulk-#{idx}",
           timestamp: DateTime.add(base, idx, :second),
           room_id: "contentops:bulk",
           actor: "loadtest",
           channel: "telegram",
           snippet: "bulk-#{String.pad_leading(Integer.to_string(idx), 3, "0")}"
         }
       end)}
    end
  end

  defmodule NotifyingInventoryStub do
    @moduledoc false

    def fetch_room_inventory do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, :inventory_fetch_called)
      {:ok, []}
    end
  end

  defmodule EmptyActionTimelineStub do
    @moduledoc false

    def fetch_action_timeline(_opts), do: {:ok, []}
  end

  defmodule PopulatedActionTimelineStub do
    @moduledoc false

    def fetch_action_timeline(_opts) do
      {:ok,
       [
         %{
           id: "action-2",
           timestamp: ~U[2026-02-18 14:29:00Z],
           type: :action,
           label: "Run weekly command",
           outcome: :blocked,
           authz_status: :unauthorized,
           mutation_enabled: true,
           actor: %{channel: :telegram, external_user_id: "999"},
           details: "You are not authorized to run ContentOps operations from chat."
         },
         %{
           id: "run-1",
           timestamp: ~U[2026-02-18 14:27:10Z],
           type: :run,
           label: "ContentOps weekly run completed",
           outcome: :succeeded,
           authz_status: :authorized,
           mutation_enabled: true,
           actor: %{channel: :telegram, external_user_id: "111"},
           details: "run_id run_123 · changes 2 · delivered 2"
         }
       ]}
    end
  end

  defmodule GuardrailIndicatorStub do
    @moduledoc false

    def fetch_guardrails do
      {:ok,
       %{
         mutation_enabled: false,
         latest_authz_status: :unauthorized,
         authz_counts: %{authorized: 1, unauthorized: 2, mutations_disabled: 1, unknown: 0},
         blocked_actions: 3
       }}
    end
  end

  setup_all do
    Application.put_env(:agent_jido, AgentJidoWeb.Endpoint,
      url: [host: "localhost"],
      http: [ip: {127, 0, 0, 1}, port: 4002],
      secret_key_base: String.duplicate("a", 64),
      render_errors: [
        formats: [html: AgentJidoWeb.ErrorHTML, json: AgentJidoWeb.ErrorJSON],
        layout: false
      ],
      pubsub_server: AgentJido.PubSub,
      live_view: [signing_salt: "chatops_test_salt"],
      server: false
    )

    for app <- [:telemetry, :plug, :plug_crypto, :phoenix_pubsub] do
      {:ok, _started} = Application.ensure_all_started(app)
    end

    unless Process.whereis(AgentJido.PubSub) do
      start_supervised!({Phoenix.PubSub, name: AgentJido.PubSub})
    end

    unless Process.whereis(AgentJidoWeb.Endpoint) do
      start_supervised!(AgentJidoWeb.Endpoint)
    end

    :ok
  end

  setup do
    {:ok, conn: build_conn()}
  end

  test "renders room inventory with bindings", %{conn: conn} do
    session = %{"chatops_inventory_provider" => PopulatedInventoryStub}

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ "ChatOps Console"
    assert html =~ "Room Inventory"
    assert html =~ "contentops:lobby"
    assert html =~ "ContentOps Lobby"
    assert html =~ "Telegram"
    assert html =~ "Discord"
    assert html =~ "645038810"
    assert html =~ "1468796189997662487"
    assert html =~ "AgentJido.ContentOps.Chat.TelegramHandler"
    assert html =~ "AgentJido.ContentOps.Chat.DiscordHandler"
    assert html =~ "Room Without Bindings"
    assert html =~ "No channel bindings configured."
    assert html =~ "Room With Partial Binding"
    assert html =~ "instance:"
    assert html =~ ">—</span>"
    assert html =~ "Recent Messages"
    assert html =~ ~s(id="chatops-message-timeline-empty")
    assert html =~ "Action/Run Timeline"
    assert html =~ "Guardrails"
  end

  test "renders empty-state inventory when no room bindings are available", %{conn: conn} do
    session = %{"chatops_inventory_provider" => EmptyInventoryStub}

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ ~s(id="chatops-room-inventory-empty")
    assert html =~ "No room bindings are currently available."
  end

  test "refresh button reloads room inventory data", %{conn: conn} do
    Application.put_env(:agent_jido, NotifyingInventoryStub, pid: self())

    on_exit(fn ->
      Application.delete_env(:agent_jido, NotifyingInventoryStub)
    end)

    session = %{"chatops_inventory_provider" => NotifyingInventoryStub}

    {:ok, view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)
    assert html =~ ~s(id="chatops-room-inventory-refresh")
    assert_receive :inventory_fetch_called, 500

    view
    |> element("#chatops-room-inventory-refresh")
    |> render_click()

    assert_receive :inventory_fetch_called, 500
  end

  test "renders empty-state message timeline when no recent messages are available", %{conn: conn} do
    session = %{
      "chatops_inventory_provider" => EmptyInventoryStub,
      "chatops_message_provider" => EmptyMessageTimelineStub
    }

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ ~s(id="chatops-message-timeline-empty")
    assert html =~ "No recent messages are available."
    assert html =~ "showing latest 50 messages"
  end

  test "renders populated message timeline with metadata formatting", %{conn: conn} do
    session = %{
      "chatops_inventory_provider" => EmptyInventoryStub,
      "chatops_message_provider" => PopulatedMessageTimelineStub
    }

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ ~s(id="chatops-message-timeline-list")
    assert html =~ "2026-02-18 14:24:00 UTC"
    assert html =~ "2026-02-18 14:22:10 UTC"
    assert html =~ "contentops:lobby"
    assert html =~ "contentops:triage"
    assert html =~ "alice"
    assert html =~ "octocat"
    assert html =~ "Telegram"
    assert html =~ "Discord"
    assert html =~ "Need status on weekly run."
    assert html =~ "Please review issue #123."
  end

  test "truncates high-volume message timeline to latest 50 entries", %{conn: conn} do
    session = %{
      "chatops_inventory_provider" => EmptyInventoryStub,
      "chatops_message_provider" => HighVolumeMessageTimelineStub
    }

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ "showing latest 50 messages"
    assert html =~ "bulk-060"
    assert html =~ "bulk-011"
    refute html =~ "bulk-010"
    assert length(Regex.scan(~r/id="chatops-message-row-\d+"/, html)) == 50
  end

  test "renders successful and blocked action/run timeline entries", %{conn: conn} do
    session = %{
      "chatops_inventory_provider" => EmptyInventoryStub,
      "chatops_message_provider" => EmptyMessageTimelineStub,
      "chatops_action_timeline_provider" => PopulatedActionTimelineStub,
      "chatops_guardrail_provider" => GuardrailIndicatorStub
    }

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ ~s(id="chatops-action-timeline-list")
    assert html =~ ~s(id="chatops-action-row-0")
    assert html =~ "Run weekly command"
    assert html =~ "ContentOps weekly run completed"
    assert html =~ "Blocked"
    assert html =~ "Unauthorized"
    assert html =~ "Succeeded"
    assert html =~ "border-red-500/50"
    assert html =~ "border-emerald-500/40"
  end

  test "renders guardrail indicators for mutation state and authz outcomes", %{conn: conn} do
    session = %{
      "chatops_inventory_provider" => EmptyInventoryStub,
      "chatops_message_provider" => EmptyMessageTimelineStub,
      "chatops_action_timeline_provider" => EmptyActionTimelineStub,
      "chatops_guardrail_provider" => GuardrailIndicatorStub
    }

    {:ok, _view, html} = live_isolated(conn, AgentJidoWeb.ChatOpsLive, session: session)

    assert html =~ ~s(id="chatops-guardrail-mutation-state")
    assert html =~ "Disabled"
    assert html =~ ~s(id="chatops-guardrail-authz-status")
    assert html =~ "Unauthorized"
    assert html =~ ~s(id="chatops-guardrail-count-authorized")
    assert html =~ ~s(id="chatops-guardrail-count-unauthorized")
    assert html =~ ~s(id="chatops-guardrail-count-mutations-disabled")
    assert html =~ ~s(id="chatops-guardrail-count-blocked-actions")
    assert html =~ ~r/id="chatops-guardrail-count-blocked-actions"[^>]*>\s*3\s*<\/p>/
  end
end
