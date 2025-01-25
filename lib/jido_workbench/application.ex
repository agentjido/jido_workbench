defmodule JidoWorkbench.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
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
      # Jido
      # {JidoWorkbench.AgentJido, name: AgentJido}
      # # Jido
      # {Task.Supervisor, name: JidoWorkbench.TaskSupervisor}
      # {Jido.Agent.Server,
      #  agent: JidoWorkbench.Jido.Agent.new("jido"), pubsub: JidoWorkbench.PubSub},
      # JidoChat.Channel.Persistence.ETS,
      # {JidoChat.Channel, name: :jido}
      # Start a worker by calling: JidoWorkbench.Worker.start_link(arg)
      # {JidoWorkbench.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JidoWorkbench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JidoWorkbenchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
