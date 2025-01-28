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

    jido_opts = [
      id: config[:id],
      dispatch: {:bus, [target: bus_name, stream: config[:stream]]},
      verbose: true,
      mode: :auto
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
      {Jido.Chat.Room, bus_name: bus_name, room_id: room_id},
      JidoWorkbench.ChatRoom,
      {JidoWorkbench.AgentJido, jido_opts}
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
