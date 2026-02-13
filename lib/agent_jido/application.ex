defmodule AgentJido.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        AgentJido.Repo,
        AgentJidoWeb.Telemetry,
        {Phoenix.PubSub, name: AgentJido.PubSub},
        {Finch, name: AgentJido.Finch},
        Arcana.TaskSupervisor
      ] ++
        arcana_embedder_children() ++
        [
          AgentJido.OGImage,
          AgentJidoWeb.Endpoint,
          AgentJido.Jido,
          {Jido.AgentServer,
           id: AgentJido.ContentOps.OrchestratorServer,
           agent: AgentJido.ContentOps.OrchestratorAgent,
           jido: AgentJido.Jido,
           name: AgentJido.ContentOps.OrchestratorServer}
        ] ++
        contentops_chat_children()

    opts = [strategy: :one_for_one, name: AgentJido.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AgentJidoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp arcana_embedder_children do
    case Arcana.embedder() do
      {Arcana.Embedder.Local, opts} -> [{Arcana.Embedder.Local, opts}]
      _other -> []
    end
  end

  defp contentops_chat_children do
    chat_config = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat, [])

    enabled =
      case chat_config do
        cfg when is_map(cfg) -> Map.get(cfg, :enabled, false)
        cfg when is_list(cfg) -> Keyword.get(cfg, :enabled, false)
        _other -> false
      end

    if enabled do
      [AgentJido.ContentOps.Chat.Supervisor]
    else
      []
    end
  end
end
