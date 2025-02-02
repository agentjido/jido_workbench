defmodule JidoWorkbench.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    config = Application.fetch_env!(:jido_workbench, :agent_jido)
    bus_name = config[:bus_name]
    room_id = config[:room_id]
    stream = config[:stream]

    jido_opts = [
      id: config[:id],
      log_level: :debug,
      output: [
        out: [
          {:pubsub, target: JidoWorkbench.PubSub, topic: "agent_jido"},
          {:console, []}
        ],
        err: [
          {:pubsub, target: JidoWorkbench.PubSub, topic: "agent_jido"},
          {:console, []}
        ],
        log: [
          {:pubsub, target: JidoWorkbench.PubSub, topic: "agent_jido"},
          {:console, []}
        ]
      ]
    ]

    room_opts = [
      bus_name: bus_name,
      room_id: room_id,
      stream: stream
    ]

    children = [
      # Start the Telemetry supervisor
      JidoWorkbenchWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: JidoWorkbench.PubSub},
      # Start Finch
      {Finch, name: JidoWorkbench.Finch},
      # Start the Endpoint (http/https)
      JidoWorkbenchWeb.Endpoint,

      # Jido Task Supervisor
      {Task.Supervisor, name: JidoWorkbench.TaskSupervisor},

      # Jido
      {Jido.Bus, name: bus_name, adapter: :in_memory},
      # {JidoWorkbench.AgentJido, jido_opts},
      {JidoWorkbench.AgentJido2, jido_opts},
      {JidoWorkbench.ChatRoom, room_opts}
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
