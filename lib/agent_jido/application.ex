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
          AgentJido.Jido
        ]

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
end
