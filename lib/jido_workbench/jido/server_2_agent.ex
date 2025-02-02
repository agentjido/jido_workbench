# A conductor receives a signal
# - Sensor state update
# - Human request
# - Some messages demand a result - queue that - that's a conversation
# - Process async
# - Send status updates to the callee while a request is outstanding
# - When request is finished, send success or error

# - Conductor determines if the signal should be routed to a plugin
# - Based on the Router and type (path) of the Signal
# - Subsystems register for paths
#   - Router instruction is a 'Dispatch' which dispatches the signal to the
#     subsystem

# - Agent knows how to filter signals based on their source
# - if an Agent is a subsystem, they only acknowledge signals from their parent
# - Subsystem agent maintains a router - processes instructions based on teh
#   router
# - Agents are only aware of their parent, themselves and children - what about
#   peers? Peers thr

defmodule JidoWorkbench.Jido.Server2Agent do
  use Jido.Agent,
    name: "Server2Agent",
    description: "Server 2 Agent",
    actions: []

  alias Jido.Signal
  require Logger

  @doc """
  Starts a new Server2Agent process with the given initial state.
  """
  @impl true
  def start_link(initial_state \\ %{}) do
    Jido.Agent.Server.start_link(
      name: __MODULE__,
      initial_state: initial_state
    )
  end

  @doc """
  Defines the child specification for supervision.
  """
  @impl true
  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :transient,
      max_restarts: 3,
      max_seconds: 5
    }
  end

  @doc """
  Initializes the agent with the given initial state.
  """
  @impl true
  def init(initial_state) do
    Logger.info("Server2Agent initializing with state: #{inspect(initial_state)}")
    {:ok, initial_state}
  end

  @doc """
  Handles synchronous signal messages.
  """
  @impl true
  def handle_call({:signal, %Signal{} = signal}, _from, state) do
    Logger.info("Server2Agent received signal via call: #{inspect(signal)}")
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Handles asynchronous signal messages.
  """
  @impl true
  def handle_cast({:signal_async, %Signal{} = signal}, state) do
    Logger.info("Server2Agent received signal via cast: #{inspect(signal)}")
    {:noreply, state}
  end

  @doc """
  Handles info messages containing signals.
  """
  @impl true
  def handle_info({:signal, %Signal{} = signal}, state) do
    Logger.info("Server2Agent received signal via info: #{inspect(signal)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:timeout, signal_ref}, state) do
    Logger.warning("Signal #{inspect(signal_ref)} timed out")
    {:noreply, state}
  end

  @impl true
  def handle_info({:signal_complete, signal_ref, result}, state) do
    Logger.info("Signal #{inspect(signal_ref)} completed with result: #{inspect(result)}")
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.error("Server2Agent received EXIT signal: #{inspect(reason)}")
    {:stop, reason, state}
  end

  def handle_info({:error, reason}, state) do
    Logger.error("Server2Agent encountered error: #{inspect(reason)}")
    {:stop, reason, state}
  end

  def handle_info(msg, state) do
    Logger.warning("Server2Agent received unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  @doc """
  Handles cleanup when the agent terminates.
  """
  @impl true
  def terminate(reason, _state) do
    Logger.info("Server2Agent terminating: #{inspect(reason)}")
    :ok
  end
end
