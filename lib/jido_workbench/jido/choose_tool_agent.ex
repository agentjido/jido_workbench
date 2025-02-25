defmodule JidoWorkbench.Jido.ChooseToolAgent do
  use Jido.Agent,
    name: "ChooseToolAgent",
    description: "Agent for selecting appropriate tools based on user messages",
    actions: [
      JidoWorkbench.Jido.ChooseTool,
      JidoWorkbench.Jido.GuessTool
    ],
    runner: Jido.Runner.Simple,
    schema: [
      available_tools: [
        type: {:list, :atom},
        required: true,
        doc: "List of available tool modules"
      ]
    ]

  alias JidoWorkbench.Jido.{ChooseTool, GuessTool}
  require Logger

  # Client API
  @impl true
  def start_link(available_tools) do
    initial_state = %{available_tools: available_tools}
    GenServer.start_link(__MODULE__, initial_state)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def choose_tool(pid, message, opts \\ []) do
    GenServer.call(pid, {:choose_tool, message, opts})
  end

  def guess_tool(pid, message, opts \\ []) do
    GenServer.call(pid, {:guess_tool, message, opts})
  end

  # Server Callbacks
  @impl true
  def init(initial_state) do
    agent = new(Jido.Util.generate_id(), initial_state)
    {:ok, agent}
  end

  @impl true
  def handle_call(:get_state, _from, agent) do
    {:reply, agent, agent}
  end

  @impl true
  def handle_call({:choose_tool, message, opts}, _from, agent) do
    params =
      Map.merge(
        %{
          message: message,
          available_tools: agent.state.available_tools
        },
        Map.new(opts)
      )

    case cmd(agent, {ChooseTool, params}, %{}, context: %{state: agent.state}) do
      {:ok, %{result: directive}} ->
        {:reply, {:ok, directive}, agent}

      {:error, reason} = error ->
        Logger.warning("Tool selection failed", error: reason)
        {:reply, error, agent}
    end
  end

  @impl true
  def handle_call({:guess_tool, message, opts}, _from, agent) do
    params =
      Map.merge(
        %{
          message: message,
          available_tools: agent.state.available_tools
        },
        Map.new(opts)
      )

    case cmd(agent, {GuessTool, params}, %{}, context: %{state: agent.state}) do
      {:ok, %{result: result}} ->
        {:reply, {:ok, result}, agent}

      {:error, reason} = error ->
        Logger.warning("Tool guessing failed", error: reason)
        {:reply, error, agent}
    end
  end
end
