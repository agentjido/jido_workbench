defmodule AgentJidoWeb.PageLive do
  @moduledoc """
  Unified LiveView for rendering pages from the Pages content system.

  Dispatches to the appropriate layout based on page category:
  - `:docs` → Docs shell with sidebar + table of contents
  - `:training` → Marketing layout with prev/next nav and metadata badges
  - `:features`, `:build`, `:community` → Marketing layout
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Analytics
  alias AgentJido.Pages
  alias AgentJidoWeb.MarkdownLinks

  import AgentJidoWeb.Jido.DocsComponents
  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(sidebar_open: true)
     |> assign(:docs_feedback, empty_docs_feedback())}
  end

  @impl true
  def handle_params(params, uri, socket) do
    parsed_uri = URI.parse(uri)
    path = parsed_uri.path || "/"
    request_url = MarkdownLinks.absolute_url(path, parsed_uri.query)

    socket =
      socket
      |> assign(:request_path, path)
      |> assign(:request_url, request_url)

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
    secondary_tabs = docs_secondary_tabs()
    sidebar = sidebar_nav("/docs")

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
       meta_description: "Reference docs and implementation guides for building reliable multi-agent systems with Jido.",
       layout_type: :docs_shell,
       category: :docs,
       documents: documents,
       selected_document: nil,
       docs_secondary_tabs: secondary_tabs,
       docs_sidebar_nav: sidebar,
       page: nil,
       markdown_action: nil,
       toc: toc
     )}
  end

  defp handle_training_index(socket) do
    modules = Pages.pages_by_category(:training)
    track_groups = build_track_groups(modules)

    {:noreply,
     assign(socket,
       page_title: "Training",
       meta_description: "Hands-on learning modules for building and operating reliable multi-agent workflows with Jido.",
       layout_type: :training_index,
       category: :training,
       modules: modules,
       track_groups: track_groups,
       page: nil,
       markdown_action: nil,
       selected_document: nil,
       toc: []
     )}
  end

  defp handle_generic_index(socket, category) do
    pages = Pages.pages_by_category(category)
    %{title: title, description: description} = generic_index_metadata(category)

    {:noreply,
     assign(socket,
       page_title: title,
       meta_description: description,
       layout_type: :marketing_shell,
       category: category,
       pages: pages,
       page: nil,
       markdown_action: nil,
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
        body_with_heading_ids = ensure_heading_ids(page.body)
        page = %{page | body: body_with_heading_ids}
        toc = build_toc(page.body)
        layout_type = layout_for(page.category)
        page_seo = page_seo(page)
        noindex? = seo_value(page_seo, :noindex) == true
        markdown_action = MarkdownLinks.markdown_action(page, socket.assigns.request_url)

        assigns = [
          page_title: page.title,
          meta_description: page_meta_description(page),
          og_description: seo_value(page_seo, :og_description),
          canonical_url: seo_value(page_seo, :canonical_url),
          robots: if(noindex?, do: ["noindex", "nofollow"]),
          og_image: seo_value(page_seo, :og_image) || page.og_image,
          layout_type: layout_type,
          category: page.category,
          page: page,
          markdown_action: markdown_action,
          selected_document: page,
          toc: toc,
          document_content: %{html: page.body, toc: toc}
        ]

        assigns =
          case page.category do
            :docs ->
              documents = Pages.pages_by_category(:docs)
              secondary_tabs = docs_secondary_tabs()
              sidebar = sidebar_nav(path)

              assigns ++
                [documents: documents, docs_secondary_tabs: secondary_tabs, docs_sidebar_nav: sidebar, docs_feedback: empty_docs_feedback()]

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
    case Pages.resolve_page_for_path(path) do
      {:ok, page, _resolution} -> page
      :error -> nil
    end
  end

  defp fallback_path("/docs" <> _), do: "/docs"
  defp fallback_path("/training" <> _), do: "/training"
  defp fallback_path("/features" <> _), do: "/features"
  defp fallback_path("/build" <> _), do: "/build"
  defp fallback_path("/community" <> _), do: "/community"
  defp fallback_path(_), do: "/"

  defp generic_index_metadata(:build) do
    %{
      title: "Build with Jido",
      description: "Implementation blueprints and practical build paths for shipping Jido-powered agent systems."
    }
  end

  defp generic_index_metadata(:community) do
    %{
      title: "Jido Community",
      description: "Learning paths, adoption playbooks, and case studies from teams building with Jido."
    }
  end

  defp generic_index_metadata(category) do
    %{
      title: category |> to_string() |> Phoenix.Naming.humanize(),
      description: "Explore practical resources for building and operating production systems with Jido."
    }
  end

  defp page_meta_description(page) do
    case page.description |> to_string() |> String.trim() do
      "" -> "Explore implementation guidance and production practices for building with Jido."
      description -> description
    end
  end

  defp page_seo(page) do
    Map.get(page, :seo, %{}) || %{}
  end

  defp seo_value(seo, key) do
    Map.get(seo, key) || Map.get(seo, Atom.to_string(key))
  end

  # --- Layout dispatch ---

  defp layout_for(:docs), do: :docs_shell
  defp layout_for(:training), do: :training_shell
  defp layout_for(:features), do: :marketing_shell
  defp layout_for(:build), do: :marketing_shell
  defp layout_for(:community), do: :marketing_shell

  # --- TOC building ---

  defp ensure_heading_ids(html_content) when is_binary(html_content) do
    {placeholder_html, pre_blocks} = extract_pre_blocks(html_content)

    normalized_html =
      case Floki.parse_fragment(placeholder_html) do
        {:ok, nodes} ->
          {nodes_with_ids, _used_ids} = add_heading_ids(nodes, MapSet.new())
          Floki.raw_html(nodes_with_ids)

        {:error, _} ->
          placeholder_html
      end

    restore_pre_blocks(normalized_html, pre_blocks)
  end

  defp ensure_heading_ids(html_content), do: to_string(html_content || "")

  @pre_block_pattern ~r/<pre\b[^>]*>.*?<\/pre>/is

  defp extract_pre_blocks(html) when is_binary(html) do
    @pre_block_pattern
    |> Regex.scan(html)
    |> Enum.map(&hd/1)
    |> Enum.with_index()
    |> Enum.reduce({html, []}, fn {block, index}, {acc_html, acc_blocks} ->
      token = "__JIDO_PRE_BLOCK_#{index}__"
      replaced = String.replace(acc_html, block, token, global: false)
      {replaced, [{token, block} | acc_blocks]}
    end)
  end

  defp restore_pre_blocks(html, blocks) when is_binary(html) and is_list(blocks) do
    Enum.reduce(blocks, html, fn {token, block}, acc ->
      String.replace(acc, token, block)
    end)
  end

  defp add_heading_ids(nodes, used_ids) when is_list(nodes) do
    Enum.map_reduce(nodes, used_ids, &add_heading_ids/2)
  end

  defp add_heading_ids({tag, attrs, children}, used_ids) when tag in ["h1", "h2", "h3"] do
    existing_id =
      attrs
      |> Enum.find_value(fn
        {"id", id} -> id
        _ -> nil
      end)
      |> normalize_heading_id()

    {children_with_ids, used_after_children} = add_heading_ids(children, used_ids)

    candidate_base =
      existing_id ||
        {tag, attrs, children_with_ids}
        |> Floki.text()
        |> slugify()

    {id, used_after_id} = reserve_unique_id(candidate_base, used_after_children)
    attrs = [{"id", id} | Enum.reject(attrs, fn {key, _value} -> key == "id" end)]

    {{tag, attrs, children_with_ids}, used_after_id}
  end

  defp add_heading_ids({tag, attrs, children}, used_ids) do
    {children_with_ids, used_after_children} = add_heading_ids(children, used_ids)
    {{tag, attrs, children_with_ids}, used_after_children}
  end

  defp add_heading_ids(other, used_ids), do: {other, used_ids}

  defp normalize_heading_id(id) when is_binary(id) do
    case String.trim(id) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_heading_id(_id), do: nil

  defp reserve_unique_id(base, used_ids) do
    base =
      case normalize_heading_id(base) do
        nil -> "section"
        normalized -> normalized
      end

    unique_id = unique_id(base, used_ids, 1)
    {unique_id, MapSet.put(used_ids, unique_id)}
  end

  defp unique_id(base, used_ids, attempt) do
    candidate =
      if attempt == 1 do
        base
      else
        "#{base}-#{attempt}"
      end

    if MapSet.member?(used_ids, candidate) do
      unique_id(base, used_ids, attempt + 1)
    else
      candidate
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

  def difficulty_badge(:beginner), do: "bg-accent-green/10 text-accent-green"
  def difficulty_badge(:intermediate), do: "bg-accent-yellow/10 text-accent-yellow"
  def difficulty_badge(:advanced), do: "bg-accent-red/10 text-accent-red"
  def difficulty_badge(_), do: "bg-elevated text-muted-foreground"

  def difficulty_class(:beginner),
    do: "bg-accent-green/10 border border-accent-green/30 text-accent-green"

  def difficulty_class(:intermediate),
    do: "bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow"

  def difficulty_class(:advanced),
    do: "bg-accent-red/10 border border-accent-red/30 text-accent-red"

  def difficulty_class(_), do: "bg-elevated border border-border text-muted-foreground"

  # --- Sidebar for docs ---

  def sidebar_nav(request_path \\ "/docs") do
    case Pages.docs_section_for_path(request_path) do
      nil -> sidebar_sections_for_overview()
      section -> sidebar_sections_for_section(section)
    end
  end

  defp docs_secondary_tabs do
    Pages.docs_sections()
    |> Enum.map(fn page ->
      section = Pages.docs_section_for_path(page.path)

      %{
        label: Map.get(page, :menu_label) || page.title,
        href: Pages.route_for(page),
        active_paths: ["/docs/#{section}"]
      }
    end)
  end

  defp sidebar_sections_for_overview do
    items =
      Pages.docs_sections()
      |> Enum.map(fn page ->
        %{label: Map.get(page, :menu_label) || page.title, href: Pages.route_for(page)}
      end)

    [%{title: "Documentation", items: items}]
  end

  defp sidebar_sections_for_section(section) do
    pages = Pages.docs_section_pages(section)
    root_page = Pages.docs_section_root(section)

    title =
      case root_page do
        nil -> section |> String.replace("-", " ") |> Phoenix.Naming.humanize()
        page -> Map.get(page, :menu_label) || page.title
      end

    items =
      pages
      |> Enum.map(fn page ->
        %{label: Map.get(page, :menu_label) || page.title, href: Pages.route_for(page)}
      end)

    [%{title: title, items: items}]
  end

  # --- Events ---

  @impl true
  def handle_event("docs_feedback_select", %{"value" => "helpful"}, socket) do
    analytics_module().track_feedback_safe(socket.assigns.current_scope, %{
      event: "feedback_submitted",
      source: "docs",
      channel: "docs_sidebar",
      path: socket.assigns.request_path || "/",
      feedback_value: "helpful",
      feedback_note: nil,
      visitor_id: get_in(socket.assigns, [:analytics_identity, :visitor_id]),
      session_id: get_in(socket.assigns, [:analytics_identity, :session_id]),
      metadata: %{
        surface: "docs_page",
        page_id: Map.get(socket.assigns.selected_document || %{}, :id)
      }
    })

    {:noreply, assign(socket, :docs_feedback, %{submitted: true, value: "helpful", note: nil})}
  end

  def handle_event("docs_feedback_select", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_docs_feedback", %{"feedback" => feedback_params}, socket) do
    feedback_value = normalize_feedback_value(Map.get(feedback_params, "value"))

    feedback_note =
      if feedback_value == "not_helpful" do
        normalize_feedback_note(Map.get(feedback_params, "note"))
      else
        nil
      end

    if feedback_value in ["helpful", "not_helpful"] do
      analytics_module().track_feedback_safe(socket.assigns.current_scope, %{
        event: "feedback_submitted",
        source: "docs",
        channel: "docs_sidebar",
        path: socket.assigns.request_path || "/",
        feedback_value: feedback_value,
        feedback_note: feedback_note,
        visitor_id: get_in(socket.assigns, [:analytics_identity, :visitor_id]),
        session_id: get_in(socket.assigns, [:analytics_identity, :session_id]),
        metadata: %{
          surface: "docs_page",
          page_id: Map.get(socket.assigns.selected_document || %{}, :id)
        }
      })

      {:noreply,
       assign(socket, :docs_feedback, %{
         submitted: true,
         value: feedback_value,
         note: feedback_note
       })}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
  end

  defp normalize_feedback_value(value) when is_binary(value) do
    case String.trim(value) do
      "helpful" -> "helpful"
      "not_helpful" -> "not_helpful"
      _ -> nil
    end
  end

  defp normalize_feedback_value(_value), do: nil

  defp normalize_feedback_note(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.slice(0, 500)
    |> case do
      "" -> nil
      note -> note
    end
  end

  defp normalize_feedback_note(_value), do: nil

  defp empty_docs_feedback do
    %{submitted: false, value: nil, note: nil}
  end

  defp analytics_module do
    Application.get_env(:agent_jido, :analytics_module, Analytics)
  end
end
