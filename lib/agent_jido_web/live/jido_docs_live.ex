defmodule AgentJidoWeb.JidoDocsLive do
  use AgentJidoWeb, :live_view
  alias AgentJido.Documentation
  import AgentJidoWeb.Jido.DocsComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Documentation", sidebar_open: true)}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    path = URI.parse(uri).path

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

  # Sidebar navigation structure
  def sidebar_nav do
    [
      %{
        title: "Getting Started",
        default_open: true,
        items: [
          %{label: "Introduction", href: "/docs"},
          %{label: "Installation", href: "/docs/installation"},
          %{label: "Quick Start", href: "/docs/quickstart"},
          %{label: "Core Concepts", href: "/docs/concepts"},
          %{label: "Production Checklist", href: "/docs/production-checklist"}
        ]
      },
      %{
        title: "Packages",
        items: [
          %{label: "jido", href: "/docs/packages/jido", badge: "CORE"},
          %{label: "jido_action", href: "/docs/packages/jido-action"},
          %{label: "jido_signal", href: "/docs/packages/jido-signal"},
          %{label: "req_llm", href: "/docs/packages/req-llm", badge: "FOUNDATION"},
          %{label: "llmdb", href: "/docs/packages/llmdb", badge: "FOUNDATION"},
          %{label: "jido_ai", href: "/docs/packages/jido-ai", badge: "AI"},
          %{label: "jido_coder", href: "/docs/packages/jido-coder", badge: "APP"}
        ]
      },
      %{
        title: "Agents",
        items: [
          %{label: "Defining Agents", href: "/docs/agents/defining"},
          %{label: "Agent Lifecycle", href: "/docs/agents/lifecycle"},
          %{label: "State Management", href: "/docs/agents/state"},
          %{label: "Supervision Trees", href: "/docs/agents/supervision"},
          %{label: "Multi-Agent Systems", href: "/docs/agents/multi-agent"}
        ]
      },
      %{
        title: "Actions & Signals",
        items: [
          %{label: "Action Schemas", href: "/docs/actions/schemas"},
          %{label: "Validation", href: "/docs/actions/validation"},
          %{label: "Signal Pub/Sub", href: "/docs/signals/pubsub"},
          %{label: "Inter-Agent Comms", href: "/docs/signals/communication"}
        ]
      },
      %{
        title: "AI & LLMs",
        items: [
          %{label: "LLM Configuration", href: "/docs/ai/llm-config"},
          %{label: "Token Budgets", href: "/docs/ai/budgets"},
          %{label: "Tool Calling", href: "/docs/ai/tools"},
          %{label: "Streaming", href: "/docs/ai/streaming"},
          %{label: "Cost Tracking", href: "/docs/ai/costs"}
        ]
      },
      %{
        title: "Production",
        items: [
          %{label: "Deployment", href: "/docs/production/deployment"},
          %{label: "Observability", href: "/docs/production/observability"},
          %{label: "Telemetry", href: "/docs/production/telemetry"},
          %{label: "Scaling", href: "/docs/production/scaling"},
          %{label: "Failure Handling", href: "/docs/production/failures"}
        ]
      },
      %{
        title: "Reference",
        items: [
          %{label: "API Reference", href: "https://hexdocs.pm/jido", external: true},
          %{label: "CLI Commands", href: "/docs/reference/cli"},
          %{label: "Configuration", href: "/docs/reference/config"},
          %{label: "Benchmarks", href: "/benchmarks"}
        ]
      }
    ]
  end
end
