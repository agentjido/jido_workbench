defmodule JidoWorkbenchWeb.BasicTaskAgentLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbenchWeb.Demos.BasicTaskAgent

  require Logger

  def __jido_demo__ do
    dir = Path.dirname(__ENV__.file) |> Path.relative_to(File.cwd!())

    %JidoWorkbench.JidoDemo.Demo{
      id: :basic_task_agent,
      name: "Basic Task Agent",
      description: "A simple task management system built using Jido Agents.",
      icon: "hero-check-circle",
      module: __MODULE__,
      category: "Task Management",
      livebook: "#{dir}/basic_task_agent.livebook",
      version: "1.0.0",
      updated_at: ~U[2024-03-15 00:00:00Z],
      status: "Active",
      documentation_url: "https://hexdocs.pm/jido/task-management.html",
      source_url: "https://github.com/jido-systems/jido/blob/main/examples/task_agent.ex",
      source_files: [
        "lib/jido_workbench/jido/basic_task_agent.ex",
        "#{dir}/basic_task_agent_live.ex",
        "#{dir}/basic_task_agent_live.html.heex"
      ],
      sections: [
        %{id: "overview", title: "Overview"},
        %{id: "architecture", title: "Architecture"},
        %{id: "implementation", title: "Implementation"},
        %{id: "demo", title: "Interactive Demo"},
        %{id: "advanced", title: "Advanced Usage"}
      ],
      related_resources: [
        %{
          title: "Jido Agents Guide",
          description: "Learn about Jido's agent system",
          icon: "hero-book-open",
          url: "https://hexdocs.pm/jido/agents.html"
        },
        %{
          title: "Task Management Example",
          description: "Full source code on GitHub",
          icon: "hero-code-bracket",
          url: "https://github.com/jido-systems/jido/tree/main/examples/task_agent"
        },
        %{
          title: "LiveView Integration",
          description: "How to use Jido with Phoenix LiveView",
          icon: "hero-puzzle-piece",
          url: "https://hexdocs.pm/jido/liveview.html"
        },
        %{
          title: "Community Discord",
          description: "Join the Jido community",
          icon: "hero-chat-bubble-left-right",
          url: "https://discord.gg/jido"
        }
      ],
      config: %{
        features: [
          "Basic agent state management with tasks",
          "Action handling for creating, updating, and completing tasks",
          "Real-time UI updates reflecting agent state changes",
          "Integration between Phoenix LiveView and Jido Agents",
          "Task prioritization and status tracking",
          "Due date management"
        ],
        related_demos: [
          :server_task_agent,
          :choose_tool_agent
        ],
        tags: ["task-management", "agents", "liveview", "beginner"],
        difficulty: "beginner",
        estimated_time: "15 minutes"
      },
      enabled: true
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
