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
          AgentJidoWeb.Endpoint
        ] ++
        agent_runtime_children() ++
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
      {Arcana.Embedder.Local, _opts} ->
        raise """
        Arcana local embedder is disabled in this project.
        Use a remote embedder (for example :openai) to avoid Nx/EXLA runtime dependencies.
        """

      _other ->
        []
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

    if enabled and chat_allowed_for_runtime?() do
      [AgentJido.ContentOps.Chat.Supervisor]
    else
      []
    end
  end

  defp chat_allowed_for_runtime? do
    server_runtime?()
  end

  defp agent_runtime_children do
    if agent_runtime_enabled?() do
      [
        {Task.Supervisor, name: AgentJido.ContentOps.TaskSupervisor},
        AgentJido.Jido,
        {Jido.AgentServer,
         id: AgentJido.ContentOps.OrchestratorServer,
         agent: AgentJido.ContentOps.OrchestratorAgent,
         jido: AgentJido.Jido,
         name: AgentJido.ContentOps.OrchestratorServer}
      ]
    else
      []
    end
  end

  defp agent_runtime_enabled? do
    case System.get_env("AGENTJIDO_RUNTIME_ENABLED") do
      nil -> server_runtime?()
      value -> String.downcase(value) in ["1", "true", "yes", "on"]
    end
  end

  defp server_runtime? do
    Enum.any?(System.argv(), &(&1 == "phx.server")) or System.get_env("PHX_SERVER") in ~w(true 1)
  end
end
