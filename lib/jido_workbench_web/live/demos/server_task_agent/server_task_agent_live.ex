defmodule JidoWorkbenchWeb.ServerTaskAgentLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.Jido.ServerTaskAgent

  def __jido_demo__ do
    %JidoWorkbench.JidoDemo.Demo{
      id: :server_task_agent,
      name: "Server Task Agent",
      description: "A simple task management system built using Jido Agents.",
      icon: "hero-check-circle",
      module: __MODULE__,
      category: "Task Management",
      source_files: ["lib/jido_workbench_web/live/demos/server_task_agent_live.ex"]
    }
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, agent_pid} = ServerTaskAgent.start_link()
    agent = ServerTaskAgent.get_state(agent_pid)

    {:ok, assign(socket, agent_pid: agent_pid, agent: agent, tasks: agent.state.tasks)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:demo}>
      <div class="max-w-4xl mx-auto px-4 py-6">
        <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Server Task Agent Demo
          </h1>
          <p class="text-gray-600 dark:text-gray-300 mb-4">
            This demo showcases a simple task management system built using Jido Agents. It demonstrates:
          </p>
          <ul class="list-disc list-inside text-gray-600 dark:text-gray-300 mb-6 ml-4">
            <li>GenServer implementation of the task agent</li>
          </ul>
          <p class="text-gray-600 dark:text-gray-300 mb-4">
            <em>Agent state is not persisted, so it will reset when the page is refreshed.</em>
          </p>

          <div class="mt-6 space-x-4">
            <.button label="Add Task" phx-click="add_task" />
          </div>

          <div class="mt-6">
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Tasks</h2>
            <div class="space-y-4">
              <%= if Enum.empty?(@tasks) do %>
                <div class="text-gray-500 dark:text-gray-400 text-center py-4">
                  No tasks yet. Click "Add Task" to create one.
                </div>
              <% else %>
                <%= for task <- @tasks do %>
                  <div class="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                    <div class="flex justify-between items-start">
                      <div class="flex items-start gap-4">
                        <input
                          type="checkbox"
                          checked={task.status == :completed}
                          phx-click="complete_task"
                          phx-value-task_id={task.id}
                          class="mt-1.5 h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                          disabled={task.status == :completed}
                        />
                        <div>
                          <h3 class={"text-lg font-medium text-gray-900 dark:text-white #{if task.status == :completed, do: "line-through", else: ""}"}>
                            {task.title}
                          </h3>
                          <p class={"text-sm text-gray-600 dark:text-gray-300 #{if task.status == :completed, do: "line-through", else: ""}"}>
                            {task.description}
                          </p>
                          <div class="mt-2 flex gap-2 text-sm">
                            <span class="px-2 py-1 rounded-full bg-blue-100 text-blue-800 dark:bg-blue-800 dark:text-blue-100">
                              {task.status}
                            </span>
                            <span class="px-2 py-1 rounded-full bg-purple-100 text-purple-800 dark:bg-purple-800 dark:text-purple-100">
                              {task.priority}
                            </span>
                            <%= if task.due_date do %>
                              <span class="px-2 py-1 rounded-full bg-green-100 text-green-800 dark:bg-green-800 dark:text-green-100">
                                Due: {Calendar.strftime(task.due_date, "%Y-%m-%d")}
                              </span>
                            <% end %>
                          </div>
                        </div>
                      </div>
                      <div class="flex gap-2">
                        <%= if task.status != :completed do %>
                          <.button
                            label="Update"
                            phx-click="update_task"
                            phx-value-task_id={task.id}
                            size="sm"
                          />
                        <% end %>
                      </div>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>

          <%= if @agent do %>
            <div class="mt-6 p-4 bg-gray-100 dark:bg-gray-700 rounded-lg overflow-x-auto">
              <pre class="text-sm text-gray-800 dark:text-gray-200 whitespace-pre-wrap"><%= inspect(@agent, pretty: true, width: 80) %></pre>
            </div>
          <% end %>
        </div>
      </div>
    </.workbench_layout>
    """
  end

  @impl true
  def handle_event("add_task", _params, %{assigns: %{agent_pid: pid}} = socket) do
    titles = ["Review Code", "Write Documentation", "Fix Bug", "Add Feature", "Refactor Module"]

    descriptions = [
      "Go through recent PRs and provide feedback",
      "Update the README with latest changes",
      "Investigate and fix the production issue",
      "Implement new user-requested functionality",
      "Clean up and optimize existing code"
    ]

    params = %{
      title: Enum.random(titles),
      description: Enum.random(descriptions),
      priority: Enum.random(["low", "medium", "high"]),
      due_date:
        DateTime.utc_now() |> DateTime.add(Enum.random(1..10), :day) |> DateTime.to_iso8601()
    }

    case ServerTaskAgent.add_task(pid, params) do
      {:ok, agent} ->
        {:noreply, update_agent_and_tasks(socket, agent)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to add task: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("update_task", %{"task_id" => task_id}, %{assigns: %{agent_pid: pid}} = socket) do
    params = %{
      task_id: task_id,
      title: "Updated Test Task",
      description: "An updated test task from the demo page",
      priority: "medium",
      status: "in_progress",
      due_date: DateTime.utc_now() |> DateTime.add(3, :day) |> DateTime.to_iso8601()
    }

    case ServerTaskAgent.update_task(pid, params) do
      {:ok, agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully!")
         |> update_agent_and_tasks(agent)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update task: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event(
        "complete_task",
        %{"task_id" => task_id},
        %{assigns: %{agent_pid: pid}} = socket
      ) do
    case ServerTaskAgent.complete_task(pid, %{task_id: task_id}) do
      {:ok, agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task completed successfully!")
         |> update_agent_and_tasks(agent)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to complete task: #{inspect(reason)}")}
    end
  end

  @impl true
  def terminate(_reason, %{assigns: %{agent_pid: pid}}) do
    # Cleanup the ServerTaskAgent when the LiveView process terminates
    Process.exit(pid, :normal)
    :ok
  end

  # Helper function to update both agent and tasks in socket assigns
  defp update_agent_and_tasks(socket, agent) do
    socket
    |> assign(:agent, agent)
    |> assign(:tasks, agent.state.tasks)
  end
end
