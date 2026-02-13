defmodule AgentJidoWeb.PageLive do
  @moduledoc """
  Unified LiveView for rendering pages from the Pages content system.

  Dispatches to the appropriate layout based on page category:
  - `:docs` → Docs shell with sidebar + table of contents
  - `:training` → Marketing layout with prev/next nav and metadata badges
  - `:features`, `:build`, `:community` → Marketing layout
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Pages
  alias AgentJido.Pages.MenuNode

  import AgentJidoWeb.Jido.DocsComponents
  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, sidebar_open: true)}
  end

  @impl true
  def handle_params(params, uri, socket) do
    path = URI.parse(uri).path
    socket = assign(socket, :request_path, path)

    case socket.assigns.live_action do
      :index -> handle_index(socket, path)
      :show -> handle_show(socket, path, params)
    end
  end

  # --- Index handlers ---

  defp handle_index(socket, "/docs" <> _) do
    handle_docs_index(socket)
  end

  defp handle_index(socket, "/training" <> _) do
    handle_training_index(socket)
  end

  defp handle_index(socket, "/" <> rest) do
    category = rest |> String.split("/") |> hd() |> String.to_existing_atom()
    handle_generic_index(socket, category)
  rescue
    _ -> handle_generic_index(socket, :docs)
  end

  defp handle_docs_index(socket) do
    documents = Pages.pages_by_category(:docs)

    toc = [
      %{id: "get-started", title: "Get Started", level: 2},
      %{id: "package-ecosystem", title: "Package Ecosystem", level: 2},
      %{id: "quickstarts", title: "Quickstarts", level: 2},
      %{id: "explore-docs", title: "Explore the Docs", level: 2},
      %{id: "quick-example", title: "Quick Example", level: 2},
      %{id: "community", title: "Join the Community", level: 2}
    ]

    {:noreply,
     assign(socket,
       page_title: "Jido Documentation",
       og_image: "https://agentjido.xyz/og/docs.png",
       layout_type: :docs_shell,
       category: :docs,
       documents: documents,
       selected_document: nil,
       page: nil,
       toc: toc
     )}
  end

  defp handle_training_index(socket) do
    modules = Pages.pages_by_category(:training)
    track_groups = build_track_groups(modules)

    {:noreply,
     assign(socket,
       page_title: "Training",
       og_image: "https://agentjido.xyz/og/training.png",
       layout_type: :training_index,
       category: :training,
       modules: modules,
       track_groups: track_groups,
       page: nil,
       selected_document: nil,
       toc: []
     )}
  end

  defp handle_generic_index(socket, category) do
    pages = Pages.pages_by_category(category)
    label = category |> to_string() |> Phoenix.Naming.humanize()

    {:noreply,
     assign(socket,
       page_title: label,
       og_image: "https://agentjido.xyz/og/default.png",
       layout_type: :marketing_shell,
       category: category,
       pages: pages,
       page: nil,
       selected_document: nil,
       toc: []
     )}
  end

  # --- Show handlers ---

  defp handle_show(socket, path, _params) do
    # Try to find page by matching path patterns
    page = find_page_for_path(path)

    case page do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Page not found")
         |> push_navigate(to: fallback_path(path))}

      page ->
        toc = build_toc(page.body)
        layout_type = layout_for(page.category)

        assigns = [
          page_title: page.title,
          og_image: page.og_image || og_image_for(page.category),
          layout_type: layout_type,
          category: page.category,
          page: page,
          selected_document: page,
          toc: toc,
          document_content: %{html: page.body, toc: toc}
        ]

        assigns =
          case page.category do
            :docs ->
              documents = Pages.pages_by_category(:docs)
              assigns ++ [documents: documents]

            :training ->
              {prev, next} = Pages.neighbors(page.id)
              assigns ++ [previous_module: prev, next_module: next]

            _ ->
              assigns
          end

        {:noreply, assign(socket, assigns)}
    end
  end

  defp find_page_for_path(path) do
    # First try exact match on the full path
    all_pages = Pages.all_pages()

    Enum.find(all_pages, fn page ->
      route = Pages.route_for(page)
      route == path || route == String.trim_trailing(path, "/")
    end)
  end

  defp fallback_path("/docs" <> _), do: "/docs"
  defp fallback_path("/training" <> _), do: "/training"
  defp fallback_path("/features" <> _), do: "/features"
  defp fallback_path("/build" <> _), do: "/build"
  defp fallback_path("/community" <> _), do: "/community"
  defp fallback_path(_), do: "/"

  # --- Layout dispatch ---

  defp layout_for(:docs), do: :docs_shell
  defp layout_for(:training), do: :training_shell
  defp layout_for(:features), do: :marketing_shell
  defp layout_for(:build), do: :marketing_shell
  defp layout_for(:community), do: :marketing_shell

  defp og_image_for(:docs), do: "https://agentjido.xyz/og/docs.png"
  defp og_image_for(:training), do: "https://agentjido.xyz/og/training.png"
  defp og_image_for(:features), do: "https://agentjido.xyz/og/features.png"
  defp og_image_for(_), do: "https://agentjido.xyz/og/default.png"

  # --- TOC building ---

  defp build_toc(html_content) do
    case Floki.parse_fragment(html_content) do
      {:ok, document} ->
        document
        |> Floki.find("h1, h2, h3")
        |> Enum.map(fn header ->
          {tag_name, attrs, _content} = header
          level = String.to_integer(String.trim_leading(tag_name, "h"))

          id =
            Enum.find_value(attrs, fn
              {"id", id} -> id
              _ -> nil
            end) || slugify(Floki.text(header))

          title = Floki.text(header)

          %{
            id: id,
            title: title,
            level: level,
            children: []
          }
        end)

      {:error, _} ->
        []
    end
  end

  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/, "-")
    |> String.trim("-")
  end

  # --- Training helpers ---

  @track_order [:foundations, :coordination, :integration, :operations]

  defp build_track_groups(modules) do
    grouped = Enum.group_by(modules, & &1.track)

    @track_order
    |> Enum.map(fn track -> {track, Map.get(grouped, track, [])} end)
    |> Enum.reject(fn {_track, track_modules} -> track_modules == [] end)
  end

  def track_label(:foundations), do: "Foundations"
  def track_label(:coordination), do: "Agent Coordination"
  def track_label(:integration), do: "App Integration"
  def track_label(:operations), do: "Production Operations"
  def track_label(track), do: track |> to_string() |> Phoenix.Naming.humanize()

  def difficulty_badge(:beginner), do: "bg-green-500/10 text-green-400"
  def difficulty_badge(:intermediate), do: "bg-amber-500/10 text-amber-400"
  def difficulty_badge(:advanced), do: "bg-red-500/10 text-red-400"
  def difficulty_badge(_), do: "bg-elevated text-muted-foreground"

  def difficulty_class(:beginner),
    do: "bg-green-500/10 border border-green-500/30 text-green-400"

  def difficulty_class(:intermediate),
    do: "bg-amber-500/10 border border-amber-500/30 text-amber-400"

  def difficulty_class(:advanced),
    do: "bg-red-500/10 border border-red-500/30 text-red-400"

  def difficulty_class(_), do: "bg-elevated border border-border text-muted-foreground"

  # --- Sidebar for docs ---

  def sidebar_nav do
    docs_node =
      Pages.menu_tree()
      |> Enum.find(fn node -> node.slug == "docs" end)

    sections = build_sections_from_node(docs_node)

    sections ++
      [
        %{
          title: "Reference",
          items: [
            %{label: "API Reference", href: "https://hexdocs.pm/jido", external: true}
          ]
        }
      ]
  end

  defp build_sections_from_node(nil), do: []

  defp build_sections_from_node(%MenuNode{children: children} = node) do
    parent_item =
      if node.doc, do: [%{label: MenuNode.label(node), href: Pages.route_for(node.doc)}], else: []

    leaf_children =
      children
      |> Enum.filter(&(&1.doc != nil && &1.children == []))
      |> Enum.sort_by(& &1.order)
      |> Enum.map(fn n -> %{label: MenuNode.label(n), href: Pages.route_for(n.doc)} end)

    top_level_items = parent_item ++ leaf_children

    child_sections =
      children
      |> Enum.filter(&(length(&1.children) > 0 && &1.doc != nil))
      |> Enum.sort_by(& &1.order)
      |> Enum.map(fn child ->
        items =
          [child | child.children]
          |> Enum.filter(&(&1.doc != nil))
          |> Enum.sort_by(& &1.order)
          |> Enum.map(fn n -> %{label: MenuNode.label(n), href: Pages.route_for(n.doc)} end)

        %{title: MenuNode.label(child), items: items}
      end)

    case top_level_items do
      [] -> child_sections
      items -> [%{title: MenuNode.label(node), items: items} | child_sections]
    end
  end

  # --- Events ---

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
  end
end
