defmodule JidoWorkbench.Jido.CharacterAgent do
  use Jido.Agent,
    name: "CharacterAgent",
    description: "Agent that can say messages",
    actions: [JidoWorkbench.Jido.Actions.Say],
    runner: Jido.Runner.Chain

  use GenServer
  require Logger

  defmodule State do
    @moduledoc """
    State for the CharacterAgent
    """
    defstruct [:name, :parent_pid, :agent]

    @type t :: %__MODULE__{
            name: String.t(),
            parent_pid: pid() | nil,
            agent: map()
          }
  end

  # Client API
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, "Greeter")
    parent_pid = Keyword.get(opts, :parent_pid)
    GenServer.start_link(__MODULE__, %{name: name, parent_pid: parent_pid})
  end

  def signal(pid, %Jido.Signal{} = signal) do
    GenServer.call(pid, {:signal, signal})
  end

  # Server Callbacks
  @impl true
  def init(initial_state) do
    agent = new(UUID.uuid4(), initial_state)
    state = struct(State, Map.put(initial_state, :agent, agent))
    {:ok, state}
  end

  @impl true
  def handle_call({:signal, %Jido.Signal{type: :say, data: message}}, _from, state) do
    # Log the action
    Logger.info("#{state.name} says: #{message}")

    # Execute Say action using cmd
    case cmd(state.agent, {JidoWorkbench.Jido.Actions.Say, %{message: message}}, %{},
           context: %{state: state.agent.state}
         ) do
      {:ok, result} ->
        # Notify parent if configured
        if state.parent_pid do
          send(state.parent_pid, {:spoken_message, message})
        end

        {:reply, {:ok, result}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
end
