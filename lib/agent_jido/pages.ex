defmodule AgentJido.Pages do
  @moduledoc """
  Unified Pages system powered by NimblePublisher.

  Replaces the separate Documentation and Training pipelines with a single
  content system that loads pages from `priv/pages/`. Category is derived
  from the first subdirectory: docs/, training/, features/, build/, community/.

  Provides:
  - Compile-time parsing and validation of .md and .livemd files
  - Pre-indexed lookups by id, path, category, and tag
  - Hierarchical menu tree with proper ordering
  - Per-category prev/next navigation helpers
  - Breadcrumb generation
  - Route generation per category
  """

  alias AgentJido.Pages.Page
  alias AgentJido.Pages.MenuNode

  use NimblePublisher,
    build: Page,
    from: Application.app_dir(:agent_jido, "priv/pages/**/*.{md,livemd}"),
    as: :pages,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html],
    parser: AgentJido.Pages.LivebookParser

  # --- Compile-time indexes ---

  @pages Enum.sort_by(@pages, & &1.order)

  @published_pages Enum.reject(@pages, & &1.draft)

  @pages_by_id Map.new(@published_pages, &{&1.id, &1})
  @pages_by_path Map.new(@published_pages, &{&1.path, &1})

  @pages_by_category @published_pages
                     |> Enum.group_by(& &1.category)
                     |> Map.new()

  @pages_by_tag @published_pages
                |> Enum.flat_map(fn page ->
                  for tag <- page.tags || [], do: {tag, page}
                end)
                |> Enum.group_by(fn {tag, _page} -> tag end, fn {_tag, page} -> page end)
                |> Map.new()

  @tags @published_pages
        |> Enum.flat_map(&(&1.tags || []))
        |> Enum.uniq()
        |> Enum.sort()

  @categories @published_pages
              |> Enum.map(& &1.category)
              |> Enum.uniq()
              |> Enum.sort()

  # --- Error module ---

  defmodule NotFoundError do
    @moduledoc """
    Raised when a page cannot be found by id or path.
    """
    defexception [:message, plug_status: 404]
  end

  # --- Public API ---

  @doc """
  Returns all published pages (excludes drafts), sorted by order.
  """
  @spec all_pages() :: [Page.t()]
  def all_pages, do: @published_pages

  @doc """
  Returns all pages including drafts, sorted by order.
  """
  @spec all_pages_including_drafts() :: [Page.t()]
  def all_pages_including_drafts, do: @pages

  @doc """
  Returns a page by its ID, raises `NotFoundError` if not found.
  """
  @spec get_page!(String.t()) :: Page.t()
  def get_page!(id) do
    Map.get(@pages_by_id, id) ||
      raise NotFoundError, "page with id=#{id} not found"
  end

  @doc """
  Returns a page by its ID, or nil if not found.
  """
  @spec get_page_by_id(String.t()) :: Page.t() | nil
  def get_page_by_id(id), do: Map.get(@pages_by_id, id)

  @doc """
  Returns a page by its path, or nil if not found.
  """
  @spec get_page_by_path(String.t()) :: Page.t() | nil
  def get_page_by_path(path), do: Map.get(@pages_by_path, path)

  @doc """
  Returns a page by its path, raises `NotFoundError` if not found.
  """
  @spec get_page_by_path!(String.t()) :: Page.t()
  def get_page_by_path!(path) do
    Map.get(@pages_by_path, path) ||
      raise NotFoundError, "page with path=#{path} not found"
  end

  @doc """
  Returns all published pages in a given category, or empty list if none.
  """
  @spec pages_by_category(atom()) :: [Page.t()]
  def pages_by_category(category) when is_atom(category) do
    Map.get(@pages_by_category, category, [])
  end

  @doc """
  Returns all published pages with a given tag, or empty list if none.
  """
  @spec pages_by_tag(atom()) :: [Page.t()]
  def pages_by_tag(tag) when is_atom(tag) do
    Map.get(@pages_by_tag, tag, [])
  end

  @doc """
  Returns all unique tags across all published pages.
  """
  @spec all_tags() :: [atom()]
  def all_tags, do: @tags

  @doc """
  Returns all unique categories across all published pages.
  """
  @spec all_categories() :: [atom()]
  def all_categories, do: @categories

  @doc """
  Returns the total number of published pages.
  """
  @spec page_count() :: non_neg_integer()
  def page_count, do: length(@published_pages)

  @doc """
  Returns the full hierarchical menu tree for all published pages.
  """
  @spec menu_tree() :: [MenuNode.t()]
  def menu_tree, do: do_build_menu_tree(@published_pages)

  @doc """
  Returns the menu tree filtered to pages in a specific category.
  """
  @spec menu_tree(atom()) :: [MenuNode.t()]
  def menu_tree(category) when is_atom(category) do
    category
    |> pages_by_category()
    |> do_build_menu_tree()
  end

  @doc """
  Returns the previous and next pages within the same category.

  ## Examples

      iex> {prev, next} = Pages.neighbors("getting-started")
      iex> prev.id
      "overview"
  """
  @spec neighbors(String.t()) :: {Page.t() | nil, Page.t() | nil}
  def neighbors(id) do
    page = get_page_by_id(id)

    if page do
      category_pages = pages_by_category(page.category)
      idx = Enum.find_index(category_pages, &(&1.id == id))
      prev = if idx && idx > 0, do: Enum.at(category_pages, idx - 1)
      next = if idx && idx < length(category_pages) - 1, do: Enum.at(category_pages, idx + 1)
      {prev, next}
    else
      {nil, nil}
    end
  end

  @doc """
  Returns breadcrumb segments for a page.

  ## Examples

      iex> Pages.breadcrumbs(%Page{path: "/docs/getting-started"})
      ["docs", "getting-started"]
  """
  @spec breadcrumbs(Page.t() | String.t()) :: [String.t()]
  def breadcrumbs(%Page{path: path}) do
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.filter(&(&1 != ""))
  end

  def breadcrumbs(path) when is_binary(path) do
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.filter(&(&1 != ""))
  end

  @doc """
  Returns breadcrumbs with page references where available.

  ## Examples

      iex> Pages.breadcrumbs_with_docs("/docs/getting-started")
      [{"docs", %Page{...}}, {"getting-started", %Page{...}}]
  """
  @spec breadcrumbs_with_docs(String.t()) :: [{String.t(), Page.t() | nil}]
  def breadcrumbs_with_docs(path) when is_binary(path) do
    segments = breadcrumbs(path)

    segments
    |> Enum.with_index()
    |> Enum.map(fn {segment, idx} ->
      partial_path = "/" <> Enum.join(Enum.take(segments, idx + 1), "/")
      page = get_page_by_path(partial_path)
      {segment, page}
    end)
  end

  @doc """
  Generates the URL route for a page based on its category.

  ## Examples

      iex> Pages.route_for(%Page{category: :docs, path: "/docs/getting-started"})
      "/docs/getting-started"

      iex> Pages.route_for(%Page{category: :training, id: "foundations-intro"})
      "/training/foundations-intro"
  """
  @spec route_for(Page.t()) :: String.t()
  def route_for(%Page{category: :docs} = p), do: "/docs/#{path_suffix(p.path)}"
  def route_for(%Page{category: :training} = p), do: "/training/#{p.id}"
  def route_for(%Page{category: :features} = p), do: "/features/#{p.id}"
  def route_for(%Page{category: :build} = p), do: "/build/#{p.id}"
  def route_for(%Page{category: :community} = p), do: "/community/#{p.id}"

  # --- Private helpers ---

  defp path_suffix(path) do
    case path |> String.trim_leading("/") |> String.split("/", parts: 2) do
      [_category, rest] -> rest
      [only] -> only
      _ -> ""
    end
  end

  defp do_build_menu_tree(pages) do
    menu_pages = Enum.filter(pages, & &1.in_menu)

    tree_map =
      Enum.reduce(menu_pages, %{}, fn page, acc ->
        segments =
          page.path
          |> String.trim("/")
          |> case do
            "" -> ["root"]
            other -> String.split(other, "/")
          end

        insert_into_tree(acc, segments, page)
      end)

    map_tree_to_sorted_list(tree_map)
  end

  defp insert_into_tree(tree, [segment], page) do
    Map.update(tree, segment, %{doc: page, children: %{}}, fn existing ->
      Map.put(existing, :doc, page)
    end)
  end

  defp insert_into_tree(tree, [segment | rest], page) do
    Map.update(tree, segment, %{doc: nil, children: insert_into_tree(%{}, rest, page)}, fn
      existing ->
        children = Map.get(existing, :children, %{})
        Map.put(existing, :children, insert_into_tree(children, rest, page))
    end)
  end

  defp map_tree_to_sorted_list(tree) do
    tree
    |> Enum.map(fn {slug, %{doc: doc, children: children_map}} ->
      %MenuNode{
        slug: slug,
        doc: doc,
        order: (doc && doc.order) || 9999,
        children: map_tree_to_sorted_list(children_map)
      }
    end)
    |> Enum.sort_by(fn %MenuNode{order: order, slug: slug} -> {order, slug} end)
  end
end
