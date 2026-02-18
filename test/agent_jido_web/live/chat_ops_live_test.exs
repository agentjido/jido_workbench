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

  defmodule NotifyingInventoryStub do
    @moduledoc false

    def fetch_room_inventory do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, :inventory_fetch_called)
      {:ok, []}
    end
  end

  setup_all do
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
    assert html =~ "Messages"
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
end
