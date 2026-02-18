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
        {RunNotifier, room_ids: Enum.map(cfg.bindings, & &1.room_id)},
        TelegramHandler
      ] ++ maybe_discord_child(discord_available?)

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
end
