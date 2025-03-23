defmodule JidoWorkbenchWeb.MenuItems do
  @moduledoc """
  Defines the menu structure for the workbench layout.
  """
  use JidoWorkbenchWeb, :live_component
  alias JidoWorkbench.LivebookRegistry
  require Logger

  @livebook_root "lib/jido_workbench_web/live"

  def menu_items() do
    # Generate dynamic menu structures for docs and examples
    docs_menu_items = build_livebook_menu(:docs)
    examples_menu_items = build_livebook_menu(:examples)

    [
      %{
        title: "",
        menu_items: [
          %{ name: :home, label: "Home", path: ~p"/", icon: nil }
          # %{
          #   name: :jido,
          #   label: "Agent Jido",
          #   path: ~p"/jido",
          #   icon: nil
          # }

        ]
      },
      %{
        title: "",
        menu_items: [
          # Main docs menu item
          %{
            name: :all_docs,
            label: "Docs",
            path: ~p"/docs",
            icon: nil,
            # Add items directly or as submenus if they have menu_items
            menu_items: get_menu_children(docs_menu_items)
          }
        ]
      },
      %{
        title: "",
        menu_items: [
          # Main examples menu item
          %{
            name: :all_examples,
            label: "Examples",
            path: ~p"/examples",
            icon: nil,
            # Add items directly or as submenus if they have menu_items
            menu_items: get_menu_children(examples_menu_items)
          }
        ]
      },
      %{
        title: "",
        menu_items: [
          %{
            name: :catalog,
            label: "Catalog",
            path: ~p"/catalog",
            icon: nil,
            menu_items: [
              %{name: :agents, label: "Agents", path: ~p"/catalog/agents", icon: nil},
              %{name: :actions, label: "Actions", path: ~p"/catalog/actions", icon: nil},
              %{name: :skills, label: "Skills", path: ~p"/catalog/skills", icon: nil},
              %{name: :sensors, label: "Sensors", path: ~p"/catalog/sensors", icon: nil}
            ]
          }
        ]
      # },
      # %{
      #   title: "",
      #   menu_items: [
      #     %{
      #       name: :settings,
      #       label: "Settings",
      #       path: ~p"/settings",
      #       icon: nil
      #     }
      #   ]
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
      icon: "hero-folder"
    }

    # Get raw livebook data
    livebooks = LivebookRegistry.get_livebooks(type)

    # Group by category and build menu structure
    category_items =
      livebooks
      |> Enum.group_by(& &1.category)
      |> Enum.filter(fn {category, _} ->
        # Only filter out exact matches of "Documentation" under :docs or "Examples" under :examples
        # This allows categories like "Basic Concepts" to appear
        not (
          (type == :docs && category == "Documentation") ||
          (type == :examples && category == "Examples")
        )
      end)
      |> Enum.map(fn {category, items} ->
        # Skip adding extra nesting if there's only one item in a category
        if length(items) == 1 && type in [:docs, :examples] do
          # Just return the direct item for single-item categories
          build_menu_item(List.first(items), type)
        else
          %{
            name: String.to_atom(category),
            label: category,
            path: ~p"/#{type}",
            icon: "hero-folder",
            menu_items:
              items
              |> Enum.sort_by(& &1.order)
              |> Enum.map(&build_menu_item(&1, type))
          }
        end
      end)
      |> Enum.sort_by(fn item ->
        # Sort items by their label (either direct items or category items)
        case item do
          %{menu_items: _} -> item.label
          _ -> item.label
        end
      end)

    [root_item | category_items]
  end

  defp build_menu_item(livebook, type) do
    %{
      name: String.to_atom(livebook.id),
      label: livebook.title,
      path: build_livebook_path(type, livebook),
      icon: livebook.icon || "hero-document",
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

  # Helper to extract menu children from the menu structure
  defp get_menu_children(menu_items) do
    # Skip the first item (All X) and return the rest
    Enum.drop(menu_items, 1)
  end
end
