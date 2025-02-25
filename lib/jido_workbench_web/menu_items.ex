defmodule JidoWorkbenchWeb.MenuItems do
  @moduledoc """
  Defines the menu structure for the workbench layout.
  """
  use JidoWorkbenchWeb, :live_component
  alias JidoWorkbench.LivebookRegistry
  require Logger

  @livebook_root "lib/jido_workbench_web/live"

  def menu_items() do
    [
      %{
        title: "",
        menu_items: [
          %{name: :home, label: "Home", path: ~p"/", icon: nil},
          %{
            name: :jido,
            label: "Agent Jido",
            path: ~p"/jido",
            icon: nil
          },
          %{
            name: :settings,
            label: "Settings",
            path: ~p"/settings",
            icon: nil
          }
        ]
      },
      %{
        title: "Examples",
        menu_items: get_cached_menu(:examples)
      },
      %{
        title: "Docs",
        menu_items: get_cached_menu(:docs)
      },
      %{
        title: "Catalog",
        menu_items: [
          %{name: :actions, label: "Actions", path: ~p"/catalog/actions", icon: nil},
          %{name: :agents, label: "Agents", path: ~p"/catalog/agents", icon: nil},
          %{name: :sensors, label: "Sensors", path: ~p"/catalog/sensors", icon: nil},
          %{name: :skills, label: "Skills", path: ~p"/catalog/skills", icon: nil}
        ]
      }
    ]
  end

  def build_livebook_menu(type) when type in [:examples, :docs] do
    get_cached_menu(type)
  end

  def find_livebook(type, demo_id) do
    # Get raw livebooks from registry
    LivebookRegistry.get_livebooks(type)
    |> Enum.find(fn item ->
      item.path
      |> Path.relative_to(Path.join(@livebook_root, to_string(type)))
      |> Path.rootname()
      |> String.trim_leading("/")
      |> String.replace("/", "-") == demo_id
    end)
    |> case do
      nil -> nil
      livebook -> build_menu_item(livebook, type)
    end
  end

  # Private Functions

  defp get_cached_menu(type) do
    # Use process dictionary to cache the menu structure
    # This is safe because LiveView processes are short-lived
    cache_key = :"livebook_menu_#{type}"

    case Process.get(cache_key) do
      nil ->
        menu = build_menu_structure(type)
        Process.put(cache_key, menu)
        menu

      menu ->
        menu
    end
  end

  defp build_menu_structure(type) do
    # Add root "All" menu item
    root_item = %{
      name: :"all_#{type}",
      label: "All #{String.capitalize(to_string(type))}",
      path: ~p"/#{type}",
      icon: nil
    }

    # Get raw livebook data
    livebooks = LivebookRegistry.get_livebooks(type)

    # Group by category and build menu structure
    category_items =
      livebooks
      |> Enum.group_by(& &1.category)
      |> Enum.map(fn {category, items} ->
        %{
          name: String.to_atom(category),
          label: category,
          path: ~p"/#{type}",
          icon: "hero-home",
          menu_items:
            items
            |> Enum.sort_by(& &1.order)
            |> Enum.map(&build_menu_item(&1, type))
        }
      end)
      |> Enum.sort_by(& &1.label)

    [root_item | category_items]
  end

  defp build_menu_item(livebook, type) do
    %{
      name: String.to_atom(livebook.id),
      label: livebook.title,
      path: build_livebook_path(type, livebook),
      icon: "hero-home",
      description: livebook.description
    }
  end

  defp build_livebook_path(type, livebook) do
    # Create a flattened identifier from the path
    identifier =
      livebook.path
      |> Path.relative_to(Path.join(@livebook_root, to_string(type)))
      |> Path.rootname()
      |> String.trim_leading("/")
      |> String.replace("/", "-")

    case type do
      :docs -> ~p"/docs/#{identifier}"
      :examples -> ~p"/examples/#{identifier}"
    end
  end
end
