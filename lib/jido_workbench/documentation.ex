defmodule JidoWorkbench.Documentation do
  @moduledoc """
  Documentation system powered by NimblePublisher.

  Provides:
  - Compile-time parsing and validation of .md and .livemd files
  - Pre-indexed lookups by id, path, category, and tag
  - Hierarchical menu tree with proper ordering
  - Prev/next navigation helpers
  - Breadcrumb generation
  """

  alias JidoWorkbench.Documentation.Document
  alias JidoWorkbench.Documentation.LivebookParser
  alias JidoWorkbench.Documentation.MenuNode

  use NimblePublisher,
    build: Document,
    from: Application.app_dir(:jido_workbench, "priv/documentation/**/*.{md,livemd}"),
    as: :documents,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html],
    parser: LivebookParser

  @documents Enum.sort_by(@documents, & &1.order)

  @published_documents Enum.reject(@documents, & &1.draft)

  @documents_by_id Map.new(@published_documents, &{&1.id, &1})
  @documents_by_path Map.new(@published_documents, &{&1.path, &1})

  @documents_by_category @published_documents
                         |> Enum.group_by(& &1.category)
                         |> Map.new()

  @documents_by_tag @published_documents
                    |> Enum.flat_map(fn doc ->
                      for tag <- doc.tags || [], do: {tag, doc}
                    end)
                    |> Enum.group_by(fn {tag, _doc} -> tag end, fn {_tag, doc} -> doc end)
                    |> Map.new()

  @tags @published_documents
        |> Enum.flat_map(&(&1.tags || []))
        |> Enum.uniq()
        |> Enum.sort()

  @categories @published_documents
              |> Enum.map(& &1.category)
              |> Enum.uniq()
              |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @doc """
  Returns all published documents (excludes drafts), sorted by order.
  """
  @spec all_documents() :: [Document.t()]
  def all_documents, do: @published_documents

  @doc """
  Returns all documents including drafts, sorted by order.
  """
  @spec all_documents_including_drafts() :: [Document.t()]
  def all_documents_including_drafts, do: @documents

  @doc """
  Returns all unique tags across all documents.
  """
  @spec all_tags() :: [atom()]
  def all_tags, do: @tags

  @doc """
  Returns all unique categories.
  """
  @spec all_categories() :: [atom()]
  def all_categories, do: @categories

  @doc """
  Returns the pre-built menu tree.
  """
  @spec menu_tree() :: [MenuNode.t()]
  def menu_tree, do: do_build_menu_tree(@published_documents)

  @doc """
  Returns a document by its ID, or nil if not found.
  """
  @spec get_document_by_id(String.t()) :: Document.t() | nil
  def get_document_by_id(id), do: Map.get(@documents_by_id, id)

  @doc """
  Returns a document by its ID, raises NotFoundError if not found.
  """
  @spec get_document_by_id!(String.t()) :: Document.t()
  def get_document_by_id!(id) do
    Map.get(@documents_by_id, id) ||
      raise NotFoundError, "document with id=#{id} not found"
  end

  @doc """
  Returns a document by its path, or nil if not found.
  """
  @spec get_document_by_path(String.t()) :: Document.t() | nil
  def get_document_by_path(path), do: Map.get(@documents_by_path, path)

  @doc """
  Returns a document by its path, raises NotFoundError if not found.
  """
  @spec get_document_by_path!(String.t()) :: Document.t()
  def get_document_by_path!(path) do
    Map.get(@documents_by_path, path) ||
      raise NotFoundError, "document with path=#{path} not found"
  end

  @doc """
  Returns all documents in a given category, or empty list if none found.
  """
  @spec documents_by_category(atom()) :: [Document.t()]
  def documents_by_category(category) when is_atom(category) do
    Map.get(@documents_by_category, category, [])
  end

  @doc """
  Returns all documents in a given category, raises NotFoundError if none found.
  """
  @spec all_documents_by_category(atom()) :: [Document.t()]
  def all_documents_by_category(category) when is_atom(category) do
    case Map.get(@documents_by_category, category, []) do
      [] -> raise NotFoundError, "documents with category=#{category} not found"
      documents -> documents
    end
  end

  @doc """
  Returns all documents with a given tag, or empty list if none found.
  """
  @spec documents_by_tag(atom()) :: [Document.t()]
  def documents_by_tag(tag), do: Map.get(@documents_by_tag, tag, [])

  @doc """
  Returns all documents with a given tag, raises NotFoundError if none found.
  """
  @spec get_documents_by_tag!(atom()) :: [Document.t()]
  def get_documents_by_tag!(tag) do
    case Map.get(@documents_by_tag, tag, []) do
      [] -> raise NotFoundError, "documents with tag=#{tag} not found"
      documents -> documents
    end
  end

  @doc """
  Returns the previous and next documents for navigation.

  ## Examples

      iex> {prev, next} = Documentation.neighbors("chat-response")
      iex> prev.id
      "tool-response"
  """
  @spec neighbors(String.t()) :: {Document.t() | nil, Document.t() | nil}
  def neighbors(id) do
    docs = @published_documents
    idx = Enum.find_index(docs, &(&1.id == id))

    prev = if idx && idx > 0, do: Enum.at(docs, idx - 1)
    next = if idx && idx < length(docs) - 1, do: Enum.at(docs, idx + 1)

    {prev, next}
  end

  @doc """
  Returns breadcrumb segments for a document.

  ## Examples

      iex> Documentation.breadcrumbs(%Document{path: "/cookbook/chat-response"})
      ["cookbook", "chat-response"]
  """
  @spec breadcrumbs(Document.t()) :: [String.t()]
  def breadcrumbs(%Document{path: path}) do
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.filter(&(&1 != ""))
  end

  @spec breadcrumbs(String.t()) :: [String.t()]
  def breadcrumbs(path) when is_binary(path) do
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.filter(&(&1 != ""))
  end

  @doc """
  Returns breadcrumbs with document references where available.

  ## Examples

      iex> Documentation.breadcrumbs_with_docs("/cookbook/chat-response")
      [{"cookbook", %Document{...}}, {"chat-response", %Document{...}}]
  """
  @spec breadcrumbs_with_docs(String.t()) :: [{String.t(), Document.t() | nil}]
  def breadcrumbs_with_docs(path) when is_binary(path) do
    segments = breadcrumbs(path)

    segments
    |> Enum.with_index()
    |> Enum.map(fn {segment, idx} ->
      partial_path = "/" <> Enum.join(Enum.take(segments, idx + 1), "/")
      doc = get_document_by_path(partial_path)
      {segment, doc}
    end)
  end

  defp do_build_menu_tree(documents) do
    menu_docs = Enum.filter(documents, & &1.in_menu)

    tree_map =
      Enum.reduce(menu_docs, %{}, fn doc, acc ->
        segments =
          doc.path
          |> String.trim("/")
          |> case do
            "" -> ["root"]
            other -> String.split(other, "/")
          end

        insert_into_tree(acc, segments, doc)
      end)

    map_tree_to_sorted_list(tree_map)
  end

  defp insert_into_tree(tree, [segment], doc) do
    Map.update(tree, segment, %{doc: doc, children: %{}}, fn existing ->
      Map.put(existing, :doc, doc)
    end)
  end

  defp insert_into_tree(tree, [segment | rest], doc) do
    Map.update(tree, segment, %{doc: nil, children: insert_into_tree(%{}, rest, doc)}, fn
      existing ->
        children = Map.get(existing, :children, %{})
        Map.put(existing, :children, insert_into_tree(children, rest, doc))
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
