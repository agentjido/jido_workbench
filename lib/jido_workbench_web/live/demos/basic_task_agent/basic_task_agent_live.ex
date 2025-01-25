defmodule JidoWorkbenchWeb.BasicTaskAgentLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.Jido.BasicTaskAgent

  require Logger

  def __jido_demo__ do
    dir = Path.dirname(__ENV__.file) |> Path.relative_to(File.cwd!())

    %JidoWorkbench.JidoDemo.Demo{
      id: :basic_task_agent,
      name: "Basic Task Agent",
      description: "A simple task management system built using Jido Agents.",
      # docs: "#{dir}/basic_task_agent.md",
      icon: "hero-check-circle",
      module: __MODULE__,
      category: "Task Management",
      source_files: [
        "#{dir}/basic_task_agent_live.ex",
        "#{dir}/basic_task_agent_live.html.heex"
      ]
    }
  end

  @impl true
  def mount(params, session, socket) do
    agent = BasicTaskAgent.new(UUID.uuid4(), %{tasks: []})
    show_layout = show_layout(params, session)

    # agent_pid = JidoWorkbench.Jido.TaskAgent.start_link()
    {:ok, assign(socket, agent: agent, show_layout: show_layout)}
  end

  @impl true
  def handle_event("add_task", _params, socket) do
    titles = ["Review Code", "Write Documentation", "Fix Bug", "Add Feature", "Refactor Module"]

    descriptions = [
      "Go through recent PRs and provide feedback",
      "Update the README with latest changes",
      "Investigate and fix the production issue",
      "Implement new user-requested functionality",
      "Clean up and optimize existing code"
    ]

    priorities = ["low", "medium", "high"]
    days_ahead = Enum.random(1..10)

    params = %{
      title: Enum.random(titles),
      description: Enum.random(descriptions),
      priority: Enum.random(priorities),
      status: "in_progress",
      due_date: DateTime.utc_now() |> DateTime.add(days_ahead, :day) |> DateTime.to_iso8601()
    }

    case BasicTaskAgent.add_task(socket.assigns.agent, params) do
      {:ok, agent} ->
        {:noreply, socket |> assign(:agent, agent)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to add task: #{reason}")}
    end
  end

  def handle_event("update_task", %{"task_id" => task_id}, socket) do
    params = %{
      task_id: task_id,
      title: "Updated Test Task",
      description: "An updated test task from the demo page",
      priority: "medium",
      status: "in_progress",
      due_date: DateTime.utc_now() |> DateTime.add(3, :day) |> DateTime.to_iso8601()
    }

    case BasicTaskAgent.update_task(socket.assigns.agent, params) do
      {:ok, agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully!")
         |> assign(:agent, agent)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update task: #{reason}")}
    end
  end

  def handle_event("complete_task", %{"task_id" => task_id}, socket) do
    params = %{task_id: task_id}

    case BasicTaskAgent.complete_task(socket.assigns.agent, params) do
      {:ok, agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task completed successfully!")
         |> assign(:agent, agent)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to complete task: #{reason}")}
    end
  end
end
