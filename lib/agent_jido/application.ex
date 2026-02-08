defmodule AgentJido.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AgentJidoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AgentJido.PubSub},
      # Start Finch
      {Finch, name: AgentJido.Finch},
      # Start the Endpoint (http/https)
      AgentJidoWeb.Endpoint,
      # Start the GitHub Stars Tracker
      {AgentJido.GithubStarsTracker, []},
      # Jido
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
end
