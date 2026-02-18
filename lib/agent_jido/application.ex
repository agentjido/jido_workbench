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
    if enabled?(:agent_jido, AgentJido.ContentOps.Chat) do
      [AgentJido.ContentOps.Chat.Supervisor]
    else
      []
    end
  end

  defp agent_runtime_children do
    if enabled?(:agent_jido, AgentJido.Jido) do
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

  defp enabled?(app, key) do
    app
    |> Application.get_env(key, [])
    |> config_enabled?()
  end

  defp config_enabled?(cfg) when is_list(cfg), do: Keyword.get(cfg, :enabled, false)
  defp config_enabled?(cfg) when is_map(cfg), do: Map.get(cfg, :enabled, false)
  defp config_enabled?(_), do: false
end
