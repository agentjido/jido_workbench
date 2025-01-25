defmodule JidoWorkbenchWeb.MenuItems do
  @moduledoc """
  Defines the menu structure for the workbench layout.
  """
  use JidoWorkbenchWeb, :live_component

  def menu_items() do
    [
      %{
        title: "",
        menu_items: [
          %{name: :home, label: "Home", path: ~p"/", icon: "hero-home"},
          %{
            name: :jido,
            label: "Agent Jido",
            path: ~p"/jido",
            icon: "hero-chat-bubble-left-ellipsis"
          },
          %{
            name: :settings,
            label: "Settings",
            path: ~p"/settings",
            icon: "hero-wrench-screwdriver"
          }
        ]
      },
      %{
        title: "Catalog",
        menu_items: [
          %{name: :actions, label: "Actions", path: ~p"/catalog/actions", icon: "hero-bolt"},
          %{name: :agents, label: "Agents", path: ~p"/catalog/agents", icon: "hero-users"},
          %{name: :sensors, label: "Sensors", path: ~p"/catalog/sensors", icon: "hero-sparkles"},
          %{name: :skills, label: "Skills", path: ~p"/catalog/skills", icon: "hero-light-bulb"}
        ]
      },
      %{
        title: "Basic Demos",
        menu_items: [
          %{
            name: :basic_task_agent,
            label: "Basic Task Agent",
            path: ~p"/demo/basic-task-agent",
            icon: "hero-check-circle"
          },
          %{
            name: :server_task_agent,
            label: "Server Task Agent",
            path: ~p"/demo/server-task-agent",
            icon: "hero-check-circle",
            menu_items: [
              %{
                name: :server_task_agent,
                label: "Server Task Agent",
                path: ~p"/demo/server-task-agent",
                icon: "hero-check-circle"
              }
            ]
          }
        ]
      },
      %{
        title: "Advanced Demos",
        menu_items: [
          %{
            name: :choose_tool_agent,
            label: "Choose Tool Agent",
            path: ~p"/demo/choose-tool-agent",
            icon: "hero-check-circle"
          }
        ]
      }
    ]
  end
end
