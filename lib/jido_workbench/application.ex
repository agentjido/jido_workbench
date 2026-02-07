defmodule JidoWorkbench.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      JidoWorkbenchWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: JidoWorkbench.PubSub},
      # Start Finch
      {Finch, name: JidoWorkbench.Finch},
      # Start the Endpoint (http/https)
      JidoWorkbenchWeb.Endpoint,
      # Start the GitHub Stars Tracker
      {JidoWorkbench.GithubStarsTracker, []},
      # Jido
      JidoWorkbench.Jido
    ]

    opts = [strategy: :one_for_one, name: JidoWorkbench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    JidoWorkbenchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
