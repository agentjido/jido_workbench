defmodule AgentJido.Search do
  @moduledoc """
  Arcana-backed site search context with normalized, UI-independent results.
  """

  import Ecto.Query

  alias Arcana.Collection
  alias Arcana.Document

  @default_limit 10
  @default_mode :hybrid
  @collections ["site_docs", "site_blog", "site_ecosystem"]
  @snippet_max_length 320

  defmodule Result do
    @moduledoc """
    Normalized site search result.
    """

    @enforce_keys [:title, :snippet, :url, :source_type]
    defstruct [:title, :snippet, :url, :source_type, :score]

    @type source_type :: :docs | :blog | :ecosystem

    @type t :: %__MODULE__{
            title: String.t(),
            snippet: String.t(),
            url: String.t(),
            source_type: source_type(),
            score: number() | nil
          }
  end

  @type query_status :: :success | :fallback
  @type search_fun :: (String.t(), keyword() -> {:ok, [map()]} | {:error, term()})
  @type document_lookup_fun :: ([map()], module() -> %{optional(String.t()) => map()})

  @doc """
  Searches Arcana across docs/blog/ecosystem collections.

  Returns normalized `t:Result.t/0` entries and always falls back to `{:ok, []}`
  on Arcana backend failures.

  ## Options

    * `:repo` - Ecto repo (defaults to `AgentJido.Repo`)
    * `:limit` - Maximum result count (default: 10)
    * `:mode` - Arcana search mode (default: `:hybrid`)
    * `:collections` - Collections to target (default: docs/blog/ecosystem)
    * `:search_fun` - Injected Arcana search function for testing
    * `:document_lookup_fun` - Injected metadata lookup function for testing

  """
  @spec query(String.t(), keyword()) :: {:ok, [Result.t()]}
  def query(query, opts \\ []) do
    case query_with_status(query, opts) do
      {:ok, results, _status} -> {:ok, results}
    end
  end

  @doc """
  Searches Arcana and returns normalized results with backend fallback status.
  """
  @spec query_with_status(String.t(), keyword()) :: {:ok, [Result.t()], query_status}
  def query_with_status(query, opts \\ [])

  def query_with_status(query, opts) when is_binary(query) do
    query = String.trim(query)

    if query == "" do
      {:ok, [], :success}
    else
      run_query(query, opts)
    end
  end

  def query_with_status(_query, _opts), do: {:ok, [], :success}

  defp run_query(query, opts) do
    repo = Keyword.get(opts, :repo, AgentJido.Repo)
    mode = Keyword.get(opts, :mode, @default_mode)
    limit = normalize_limit(Keyword.get(opts, :limit, @default_limit))
    collections = Keyword.get(opts, :collections, @collections)
    search_fun = Keyword.get(opts, :search_fun, &Arcana.search/2)
    document_lookup_fun = Keyword.get(opts, :document_lookup_fun, &fetch_document_index/2)

    search_opts = [repo: repo, collections: collections, limit: limit, mode: mode]

    with {:ok, rows} when is_list(rows) <- safe_search(search_fun, query, search_opts) do
      docs_by_id = safe_document_lookup(document_lookup_fun, rows, repo)
      {:ok, normalize_results(rows, docs_by_id), :success}
    else
      _ -> {:ok, [], :fallback}
    end
  rescue
    _ -> {:ok, [], :fallback}
  end

  @doc """
  Default Arcana collections used for site-wide search.
  """
  @spec collections() :: [String.t()]
  def collections, do: @collections

  defp safe_search(search_fun, query, opts) do
    search_fun.(query, opts)
  rescue
    _ -> {:error, :search_failed}
  catch
    _, _ -> {:error, :search_failed}
  end

  defp safe_document_lookup(document_lookup_fun, rows, repo) do
    document_lookup_fun.(rows, repo)
  rescue
    _ -> %{}
  catch
    _, _ -> %{}
  end

  defp fetch_document_index(rows, repo) do
    document_ids =
      rows
      |> Enum.map(&value(&1, :document_id))
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

    if document_ids == [] do
      %{}
    else
      query =
        from(d in Document,
          left_join: c in Collection,
          on: c.id == d.collection_id,
          where: d.id in ^document_ids,
          select: %{
            id: d.id,
            source_id: d.source_id,
            collection: c.name,
            metadata: d.metadata
          }
        )

      repo
      |> then(& &1.all(query))
      |> Map.new(&{&1.id, &1})
    end
  end

  defp normalize_results(rows, docs_by_id) when is_map(docs_by_id) do
    Enum.map(rows, &normalize_result(&1, docs_by_id))
  end

  defp normalize_results(rows, _docs_by_id), do: Enum.map(rows, &normalize_result(&1, %{}))

  defp normalize_result(row, docs_by_id) do
    document_id = value(row, :document_id)
    doc = if is_binary(document_id), do: Map.get(docs_by_id, document_id, %{}), else: %{}
    metadata = value(doc, :metadata, %{})
    collection = value(doc, :collection)
    source_id = value(doc, :source_id)
    source_type = resolve_source_type(collection, metadata)

    %Result{
      title: resolve_title(metadata, source_type),
      snippet: resolve_snippet(row, metadata),
      url: resolve_url(collection, metadata, source_id),
      source_type: source_type,
      score: resolve_score(value(row, :score))
    }
  end

  defp resolve_title(metadata, source_type) do
    string_value(metadata, :title) ||
      string_value(metadata, :name) ||
      string_value(metadata, :id) ||
      default_title(source_type)
  end

  defp resolve_snippet(row, metadata) do
    row
    |> value(:text)
    |> normalize_string()
    |> case do
      nil -> string_value(metadata, :description) || string_value(metadata, :tagline) || ""
      text -> text
    end
    |> trim_snippet(@snippet_max_length)
  end

  defp resolve_url(collection, metadata, source_id) do
    string_value(metadata, :url) ||
      canonical_route(collection, metadata, source_id) ||
      "/"
  end

  defp resolve_source_type(collection, metadata) do
    case normalize_collection(collection) do
      "site_docs" -> :docs
      "site_blog" -> :blog
      "site_ecosystem" -> :ecosystem
      _ -> resolve_source_type_from_metadata(metadata)
    end
  end

  defp resolve_source_type_from_metadata(metadata) do
    case string_value(metadata, :source_type) do
      "documentation" -> :docs
      "docs" -> :docs
      "blog" -> :blog
      "ecosystem" -> :ecosystem
      _ -> :docs
    end
  end

  defp canonical_route(collection, metadata, source_id) do
    case normalize_collection(collection) do
      "site_docs" ->
        string_value(metadata, :path) || docs_route_from_source_id(source_id)

      "site_blog" ->
        case string_value(metadata, :id) || source_id_suffix(source_id, "blog:") do
          nil -> nil
          id -> "/blog/" <> id
        end

      "site_ecosystem" ->
        case string_value(metadata, :id) || source_id_suffix(source_id, "ecosystem:") do
          nil -> nil
          id -> "/ecosystem#" <> id
        end

      _ ->
        nil
    end
  end

  defp docs_route_from_source_id(source_id) do
    source_id
    |> source_id_suffix("docs:")
    |> case do
      nil ->
        nil

      suffix ->
        if String.starts_with?(suffix, "/") do
          suffix
        else
          "/" <> suffix
        end
    end
  end

  defp source_id_suffix(source_id, prefix) when is_binary(source_id) and is_binary(prefix) do
    if String.starts_with?(source_id, prefix) do
      source_id
      |> String.replace_prefix(prefix, "")
      |> normalize_string()
    else
      nil
    end
  end

  defp source_id_suffix(_source_id, _prefix), do: nil

  defp default_title(:docs), do: "Documentation"
  defp default_title(:blog), do: "Blog"
  defp default_title(:ecosystem), do: "Ecosystem"

  defp normalize_collection(value) when is_binary(value), do: String.trim(value)
  defp normalize_collection(value) when is_atom(value), do: Atom.to_string(value)
  defp normalize_collection(_value), do: nil

  defp resolve_score(score) when is_integer(score), do: score * 1.0
  defp resolve_score(score) when is_float(score), do: score
  defp resolve_score(_score), do: nil

  defp trim_snippet(text, max_len) when is_binary(text) do
    if String.length(text) <= max_len do
      text
    else
      String.slice(text, 0, max_len) <> "..."
    end
  end

  defp trim_snippet(_text, _max_len), do: ""

  defp normalize_limit(limit) when is_integer(limit) and limit > 0, do: limit
  defp normalize_limit(_limit), do: @default_limit

  defp normalize_string(value) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" -> nil
      text -> text
    end
  end

  defp normalize_string(_value), do: nil

  defp string_value(map, key) do
    map
    |> value(key)
    |> normalize_string()
  end

  defp value(map, key, default \\ nil)

  defp value(map, key, default) when is_map(map) and is_atom(key) do
    case Map.fetch(map, key) do
      {:ok, found} ->
        found

      :error ->
        Map.get(map, Atom.to_string(key), default)
    end
  end

  defp value(map, key, default) when is_map(map), do: Map.get(map, key, default)
  defp value(_map, _key, default), do: default
end
