defmodule AgentJidoWeb.JidoDocsLive do
  use AgentJidoWeb, :live_view
  alias AgentJido.Documentation
  alias AgentJido.Documentation.MenuNode
  import AgentJidoWeb.Jido.DocsComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Documentation", sidebar_open: true, og_image: "https://agentjido.xyz/og/docs.png")}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    path = URI.parse(uri).path
    socket = assign(socket, :request_path, path)

    case path do
      "/docs" -> handle_index(socket)
      _ -> handle_show(socket, path)
    end
  end

  defp handle_index(socket) do
    # Get all docs
    documents =
      try do
        Documentation.all_documents_by_category(:docs)
      rescue
        _ -> []
      end

    # Build table of contents
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
       documents: documents,
       selected_document: nil,
       toc: toc
     )}
  end

  defp handle_show(socket, path) do
    try do
      documents = Documentation.all_documents_by_category(:docs)

      document =
        Enum.find(documents, fn doc ->
          path == doc.path || path == String.trim_trailing(doc.path, "/")
        end)

      case document do
        nil ->
          {:noreply,
           socket
           |> put_flash(:error, "Document not found")
           |> push_navigate(to: "/docs")}

        doc ->
          toc = build_toc(doc.body)

          {:noreply,
           assign(socket,
             page_title: doc.title,
             documents: documents,
             selected_document: doc,
             toc: toc,
             document_content: %{html: doc.body, toc: toc}
           )}
      end
    rescue
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error loading document")
         |> push_navigate(to: "/docs")}
    end
  end

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

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
  end

  def sidebar_nav do
    docs_node =
      Documentation.menu_tree()
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
      if node.doc, do: [%{label: MenuNode.label(node), href: node.doc.path}], else: []

    leaf_children =
      children
      |> Enum.filter(&(&1.doc != nil && &1.children == []))
      |> Enum.sort_by(& &1.order)
      |> Enum.map(fn n -> %{label: MenuNode.label(n), href: n.doc.path} end)

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
          |> Enum.map(fn n -> %{label: MenuNode.label(n), href: n.doc.path} end)

        %{title: MenuNode.label(child), items: items}
      end)

    case top_level_items do
      [] -> child_sections
      items -> [%{title: MenuNode.label(node), items: items} | child_sections]
    end
  end
end
