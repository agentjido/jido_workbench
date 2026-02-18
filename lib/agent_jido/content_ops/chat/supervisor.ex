defmodule AgentJido.ContentOps.Chat.Supervisor do
  @moduledoc """
  Supervisor for the ContentOps chat subsystem.
  """

  use Supervisor

  require Logger

  alias AgentJido.ContentOps.Chat.{
    Config,
    BindingBootstrapper,
    Bridge,
    ChatAgentRunner,
    DiscordHandler,
    RunNotifier,
    RunStore,
    SessionManager,
    TelegramHandler
  }

  alias AgentJido.ContentOps.Messaging

  @doc "Starts the ContentOps chat supervisor."
  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(_opts) do
    cfg = Config.load!()
    discord_available? = ensure_discord_runtime()

    room_ids = Enum.map(cfg.bindings, & &1.room_id)

    children =
      [
        Messaging,
        RunStore,
        SessionManager,
        {BindingBootstrapper,
         instance_module: Messaging,
         bindings: cfg.bindings,
         telegram_instance_id: to_string(TelegramHandler),
         discord_instance_id: to_string(DiscordHandler)},
        {Bridge, instance_module: Messaging},
        {RunNotifier, room_ids: room_ids},
        TelegramHandler
      ] ++
        maybe_discord_child(discord_available?) ++
        chat_agent_children(room_ids)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp ensure_discord_runtime do
    case Application.ensure_all_started(:nostrum) do
      {:ok, _started_apps} ->
        true

      {:error, reason} ->
        Logger.error("[ContentOps.Chat.Supervisor] Discord disabled; failed to start :nostrum: #{inspect(reason)}")

        false
    end
  end

  defp maybe_discord_child(true), do: [DiscordHandler]
  defp maybe_discord_child(false), do: []

  defp chat_agent_children(room_ids) do
    runner_children = [
      {ChatAgentRunner, jido_name: AgentJido.Jido}
    ]

    agent_runner_children =
      Enum.map(room_ids, fn room_id ->
        {JidoMessaging.AgentRunner,
         room_id: room_id, agent_id: "chat_agent", agent_config: ChatAgentRunner.agent_config(), instance_module: Messaging}
      end)

    runner_children ++ agent_runner_children
  end
end
