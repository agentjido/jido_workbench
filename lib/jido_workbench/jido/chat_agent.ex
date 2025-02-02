defmodule JidoWorkbench.Jido.ChatAgent do
  alias Jido.Actions.Arithmetic

  use Jido.Agent,
    name: "AgentJido",
    description: "Jido agent",
    actions: [
      JidoWorkbench.Actions.GenerateChatResponse,
      Arithmetic.Add,
      Arithmetic.Subtract,
      Arithmetic.Multiply,
      Arithmetic.Divide,
      Arithmetic.Square
    ],
    runner: Jido.Runner.Chain

  require Logger

  # Client API
  @impl true
  def start_link(initial_state \\ %{messages: []}) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def chat_response(pid, params) do
    GenServer.call(pid, {:chat_response, params}, 30_000)
  end

  def add(pid, params) do
    GenServer.call(pid, {:add, params})
  end

  def subtract(pid, params) do
    GenServer.call(pid, {:subtract, params})
  end

  def multiply(pid, params) do
    GenServer.call(pid, {:multiply, params})
  end

  def divide(pid, params) do
    GenServer.call(pid, {:divide, params})
  end

  def square(pid, params) do
    GenServer.call(pid, {:square, params})
  end

  # Server Callbacks
  @impl true
  def init(initial_state) do
    agent = new(UUID.uuid4(), initial_state)
    {:ok, agent}
  end

  @impl true
  def handle_call(:get_state, _from, agent) do
    {:reply, agent, agent}
  end

  @impl true
  def handle_call({:chat_response, params}, from, agent) do
    Task.start(fn ->
      result =
        case cmd(agent, {JidoWorkbench.Actions.GenerateChatResponse, params}, %{},
               timeout: 25_000
             ) do
          {:ok, updated_agent} ->
            GenServer.reply(from, {:ok, updated_agent.result.result_state.result})
            updated_agent

          {:error, reason} ->
            Logger.error("Chat response error: #{inspect(reason)}")
            GenServer.reply(from, {:error, reason})
            agent
        end

      {:noreply, result}
    end)

    {:noreply, agent}
  end

  @impl true
  def handle_call({:add, params}, _from, agent) do
    case cmd(agent, {Arithmetic.Add, params}, %{}) do
      {:ok, updated_agent} -> {:reply, {:ok, updated_agent}, updated_agent}
      error -> {:reply, error, agent}
    end
  end

  @impl true
  def handle_call({:subtract, params}, _from, agent) do
    case cmd(agent, {Arithmetic.Subtract, params}, %{}) do
      {:ok, updated_agent} -> {:reply, {:ok, updated_agent}, updated_agent}
      error -> {:reply, error, agent}
    end
  end

  @impl true
  def handle_call({:multiply, params}, _from, agent) do
    case cmd(agent, {Arithmetic.Multiply, params}, %{}) do
      {:ok, updated_agent} -> {:reply, {:ok, updated_agent}, updated_agent}
      error -> {:reply, error, agent}
    end
  end

  @impl true
  def handle_call({:divide, params}, _from, agent) do
    case cmd(agent, {Arithmetic.Divide, params}, %{}) do
      {:ok, updated_agent} -> {:reply, {:ok, updated_agent}, updated_agent}
      error -> {:reply, error, agent}
    end
  end

  @impl true
  def handle_call({:square, params}, _from, agent) do
    case cmd(agent, {Arithmetic.Square, params}, %{}) do
      {:ok, updated_agent} -> {:reply, {:ok, updated_agent}, updated_agent}
      error -> {:reply, error, agent}
    end
  end
end
