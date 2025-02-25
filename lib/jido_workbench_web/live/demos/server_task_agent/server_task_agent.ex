defmodule JidoWorkbenchWeb.Demos.ServerTaskAgent do
  use Jido.Agent,
    name: "AgentTasker",
    description: "Task management agent for maintaining todo lists",
    actions: [
      JidoWorkbench.Actions.AddTask,
      JidoWorkbench.Actions.CompleteTask,
      JidoWorkbench.Actions.ListTasks,
      JidoWorkbench.Actions.UpdateTask
    ],
    runner: Jido.Runner.Simple,
    schema: [
      tasks: [type: {:list, :map}, required: true, doc: "List of tasks"]
    ]

  # alias JidoWorkbench.Actions.{AddTask, ListTasks, UpdateTask, CompleteTask}
  # require Logger

  # # Client API
  # def start_link(initial_tasks \\ []) do
  #   # Initialize with direct tasks array instead of wrapped state
  #   initial_state = %{tasks: initial_tasks}
  #   GenServer.start_link(__MODULE__, initial_state)
  # end

  # def get_state(pid) do
  #   GenServer.call(pid, :get_state)
  # end

  # def add_task(pid, params) do
  #   GenServer.call(pid, {:add_task, params})
  # end

  # def list_tasks(pid, params) do
  #   GenServer.call(pid, {:list_tasks, params})
  # end

  # def update_task(pid, params) do
  #   GenServer.call(pid, {:update_task, params})
  # end

  # def complete_task(pid, params) do
  #   GenServer.call(pid, {:complete_task, params})
  # end

  # # Server Callbacks
  # @impl true
  # def init(initial_state) do
  #   agent = new(Jido.Util.generate_id(), initial_state)
  #   {:ok, agent}
  # end

  # @impl true
  # def handle_call(:get_state, _from, agent) do
  #   {:reply, agent, agent}
  # end

  # @impl true
  # def handle_call({:add_task, params}, _from, agent) do
  #   case cmd(agent, {AddTask, params}, %{}, context: %{state: agent.state}) do
  #     {:ok, updated_agent} ->
  #       {:reply, {:ok, updated_agent}, updated_agent}

  #     error ->
  #       {:reply, error, agent}
  #   end
  # end

  # @impl true
  # def handle_call({:list_tasks, params}, _from, agent) do
  #   case cmd(agent, {ListTasks, params}, %{}, context: %{state: agent.state}) do
  #     {:ok, %{result: tasks}} ->
  #       {:reply, {:ok, tasks}, agent}

  #     error ->
  #       {:reply, error, agent}
  #   end
  # end

  # @impl true
  # def handle_call({:update_task, params}, _from, agent) do
  #   case cmd(agent, {UpdateTask, params}, %{}, context: %{state: agent.state}) do
  #     {:ok, updated_agent} ->
  #       {:reply, {:ok, updated_agent}, updated_agent}

  #     error ->
  #       {:reply, error, agent}
  #   end
  # end

  # @impl true
  # def handle_call({:complete_task, params}, _from, agent) do
  #   case cmd(agent, {CompleteTask, params}, %{}, context: %{state: agent.state}) do
  #     {:ok, updated_agent} ->
  #       {:reply, {:ok, updated_agent}, updated_agent}

  #     error ->
  #       {:reply, error, agent}
  #   end
  # end
end
