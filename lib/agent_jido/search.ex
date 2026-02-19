defmodule AgentJido.Search do
  @moduledoc """
  Arcana-backed site search context with normalized, UI-independent results.
  """

  import Ecto.Query

  alias AgentJido.Blog
  alias AgentJido.Ecosystem
  alias AgentJido.Pages
  alias Arcana.Collection
  alias Arcana.Document

  @default_limit 10
  @default_mode :hybrid
  @collections ["site_docs", "site_blog", "site_ecosystem"]
  @snippet_max_length 320
  @disabled_route_prefixes ["/training", "/search"]

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
  @type fallback_fun :: (String.t(), keyword() -> [Result.t()])

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
    * `:fallback_fun` - Injected local fallback function for backend failure scenarios

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
    fallback_fun = Keyword.get(opts, :fallback_fun, &local_fallback_query/2)

    search_opts = [repo: repo, collections: collections, limit: limit, mode: mode]

    try do
      with {:ok, rows} when is_list(rows) <- safe_search(search_fun, query, search_opts) do
        docs_by_id = safe_document_lookup(document_lookup_fun, rows, repo)

        normalized_results =
          rows
          |> normalize_results(docs_by_id)

        primary_results = filter_disabled_results(normalized_results, limit)

        cond do
          primary_results != [] ->
            {:ok, primary_results, :success}

          # Backend returned rows but all normalized results were retired routes
          # (for example /training). In this case, try fallback before returning empty.
          normalized_results != [] ->
            fallback_response(fallback_fun, query, limit)

          true ->
            {:ok, [], :success}
        end
      else
        _ -> fallback_response(fallback_fun, query, limit)
      end
    rescue
      _ -> fallback_response(fallback_fun, query, limit)
    end
  end

  defp fallback_response(fallback_fun, query, limit) do
    fallback_results =
      safe_fallback_search(fallback_fun, query, limit)
      |> filter_disabled_results(limit)

    status = if fallback_results == [], do: :fallback, else: :success
    {:ok, fallback_results, status}
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

  defp safe_fallback_search(fallback_fun, query, limit) do
    fallback_fun.(query, limit: limit)
    |> normalize_fallback_results(limit)
  rescue
    _ -> []
  catch
    _, _ -> []
  end

  defp normalize_fallback_results(results, limit) when is_list(results) do
    results
    |> Enum.filter(&match?(%Result{}, &1))
    |> Enum.take(limit)
  end

  defp normalize_fallback_results(_results, _limit), do: []

  defp local_fallback_query(query, opts) do
    limit = normalize_limit(Keyword.get(opts, :limit, @default_limit))
    terms = tokenize_query(query)

    if terms == [] do
      []
    else
      query_downcase = String.downcase(query)

      page_results =
        Pages.all_pages()
        |> Enum.reject(&(&1.category == :training))
        |> Enum.map(&build_page_fallback_result(&1, terms, query_downcase))

      blog_results =
        Blog.all_posts()
        |> Enum.map(&build_blog_fallback_result(&1, terms, query_downcase))

      ecosystem_results =
        Ecosystem.public_packages()
        |> Enum.map(&build_ecosystem_fallback_result(&1, terms, query_downcase))

      (page_results ++ blog_results ++ ecosystem_results)
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(&(&1.score || 0.0), :desc)
      |> filter_disabled_results(limit)
    end
  end

  defp filter_disabled_results(results, limit) when is_list(results) do
    results
    |> Enum.reject(&disabled_result?/1)
    |> Enum.take(limit)
  end

  defp filter_disabled_results(_results, _limit), do: []

  defp disabled_result?(%Result{url: url}) when is_binary(url), do: disabled_path?(url)
  defp disabled_result?(_result), do: false

  defp disabled_path?(url) when is_binary(url) do
    case URI.parse(url).path do
      nil ->
        false

      path when is_binary(path) ->
        Enum.any?(@disabled_route_prefixes, fn prefix ->
          path == prefix or String.starts_with?(path, prefix <> "/")
        end)
    end
  end

  defp build_page_fallback_result(page, terms, query_downcase) do
    title = normalize_string(page.title) || default_title(:docs)
    description = normalize_string(page.description)
    body_text = strip_html(page.body)
    searchable_text = join_searchable_text([description, body_text])
    score = lexical_score(title, searchable_text, terms, query_downcase)

    if score > 0 do
      snippet_source =
        case description do
          nil -> body_text
          description_text -> description_text <> " " <> body_text
        end

      %Result{
        title: title,
        snippet: snippet_for(snippet_source, query_downcase),
        url: Pages.route_for(page),
        source_type: :docs,
        score: score
      }
    end
  end

  defp build_blog_fallback_result(post, terms, query_downcase) do
    title = normalize_string(post.title) || default_title(:blog)
    description = normalize_string(post.description)
    body_text = strip_html(post.body)
    searchable_text = join_searchable_text([description, body_text, Enum.join(post.tags || [], " ")])
    score = lexical_score(title, searchable_text, terms, query_downcase)

    if score > 0 do
      snippet_source =
        case description do
          nil -> body_text
          description_text -> description_text <> " " <> body_text
        end

      %Result{
        title: title,
        snippet: snippet_for(snippet_source, query_downcase),
        url: "/blog/#{post.id}",
        source_type: :blog,
        score: score
      }
    end
  end

  defp build_ecosystem_fallback_result(package, terms, query_downcase) do
    title = normalize_string(package.title || package.name) || default_title(:ecosystem)
    description = normalize_string(package.description || package.tagline)
    body_text = strip_html(package.body)

    features =
      package.key_features
      |> List.wrap()
      |> Enum.join(" ")

    searchable_text = join_searchable_text([description, features, body_text, package.id, package.name])
    score = lexical_score(title, searchable_text, terms, query_downcase)

    if score > 0 do
      snippet_source =
        case description do
          nil -> body_text
          description_text -> description_text <> " " <> body_text
        end

      %Result{
        title: title,
        snippet: snippet_for(snippet_source, query_downcase),
        url: "/ecosystem##{package.id}",
        source_type: :ecosystem,
        score: score
      }
    end
  end

  defp tokenize_query(query) when is_binary(query) do
    query
    |> String.downcase()
    |> String.split(~r/[^[:alnum:]_]+/u, trim: true)
    |> Enum.uniq()
  end

  defp tokenize_query(_query), do: []

  defp join_searchable_text(parts) do
    parts
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  defp lexical_score(title, searchable_text, terms, query_downcase) do
    title_down = String.downcase(title || "")
    text_down = String.downcase(searchable_text || "")

    phrase_title_bonus = if query_downcase != "" and String.contains?(title_down, query_downcase), do: 6.0, else: 0.0
    phrase_text_bonus = if query_downcase != "" and String.contains?(text_down, query_downcase), do: 3.0, else: 0.0

    term_bonus =
      Enum.reduce(terms, 0.0, fn term, acc ->
        title_hits = count_occurrences(title_down, term) * 2
        text_hits = count_occurrences(text_down, term)
        acc + title_hits + text_hits
      end)

    phrase_title_bonus + phrase_text_bonus + term_bonus
  end

  defp count_occurrences(_text, term) when term in [nil, ""], do: 0

  defp count_occurrences(text, term) when is_binary(text) do
    text
    |> String.split(term)
    |> length()
    |> Kernel.-(1)
    |> max(0)
  end

  defp snippet_for(nil, _query_downcase), do: ""

  defp snippet_for(text, query_downcase) when is_binary(text) do
    clean_text =
      text
      |> strip_html()
      |> normalize_string()
      |> case do
        nil -> ""
        normalized -> normalized
      end

    if clean_text == "" do
      ""
    else
      downcase_text = String.downcase(clean_text)

      excerpt =
        case :binary.match(downcase_text, query_downcase) do
          {match_index, _match_len} when is_integer(match_index) ->
            start_index = max(match_index - 90, 0)
            String.slice(clean_text, start_index, 240)

          :nomatch ->
            String.slice(clean_text, 0, 240)
        end

      trim_snippet(excerpt, @snippet_max_length)
    end
  end

  defp strip_html(text) when is_binary(text) do
    text
    |> String.replace(~r/<[^>]*>/u, " ")
    |> String.replace(~r/\s+/u, " ")
    |> String.trim()
  end

  defp strip_html(_text), do: ""

  defp fetch_document_index(rows, repo) do
    document_ids =
      rows
      |> Enum.map(&value(&1, :document_id))
      |> Enum.map(&normalize_uuid/1)
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
    raw_document_id = value(row, :document_id)

    normalized_document_id =
      row
      |> value(:document_id)
      |> normalize_uuid()

    doc = document_for_row(docs_by_id, raw_document_id, normalized_document_id)
    row_metadata = value(row, :metadata, %{}) |> normalize_metadata()
    doc_metadata = value(doc, :metadata, %{}) |> normalize_metadata()
    metadata = Map.merge(row_metadata, doc_metadata)
    collection = value(doc, :collection)
    source_id = value(doc, :source_id)
    source_type = resolve_source_type(collection, metadata)

    %Result{
      title: resolve_title(metadata, source_type),
      snippet: resolve_snippet(row, metadata),
      url: resolve_url(row, collection, metadata, source_id),
      source_type: source_type,
      score: resolve_score(value(row, :score))
    }
  end

  defp document_for_row(docs_by_id, raw_document_id, normalized_document_id) when is_map(docs_by_id) do
    cond do
      is_binary(normalized_document_id) and Map.has_key?(docs_by_id, normalized_document_id) ->
        Map.get(docs_by_id, normalized_document_id, %{})

      Map.has_key?(docs_by_id, raw_document_id) ->
        Map.get(docs_by_id, raw_document_id, %{})

      true ->
        %{}
    end
  end

  defp document_for_row(_docs_by_id, _raw_document_id, _normalized_document_id), do: %{}

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

  defp resolve_url(row, collection, metadata, source_id) do
    canonical_route(collection, metadata, source_id) ||
      normalize_internal_url(string_value(metadata, :url)) ||
      row_text_route(row) ||
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
        normalize_internal_url(string_value(metadata, :path)) ||
          docs_route_from_source_id(source_id)

      "site_blog" ->
        case string_value(metadata, :id) || source_id_suffix(source_id, "blog:") do
          nil -> nil
          id -> normalize_internal_url("/blog/" <> id)
        end

      "site_ecosystem" ->
        case string_value(metadata, :id) || source_id_suffix(source_id, "ecosystem:") do
          nil -> nil
          id -> normalize_internal_url("/ecosystem#" <> id)
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
        normalized =
          if String.starts_with?(suffix, "/") do
            suffix
          else
            "/" <> suffix
          end

        normalize_internal_url(normalized)
    end
  end

  defp row_text_route(row) do
    row
    |> value(:text)
    |> extract_route_from_text()
  end

  defp extract_route_from_text(text) when is_binary(text) do
    text
    |> String.split(~r/\R/u, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.find_value(&normalize_internal_url/1)
  end

  defp extract_route_from_text(_text), do: nil

  defp normalize_internal_url(nil), do: nil

  defp normalize_internal_url(url) when is_binary(url) do
    candidate = String.trim(url)

    cond do
      candidate == "" ->
        nil

      String.starts_with?(candidate, "/") ->
        normalize_path(candidate)

      true ->
        case URI.parse(candidate) do
          %URI{scheme: scheme, host: host, path: path, query: query, fragment: fragment}
          when scheme in ["http", "https"] and is_binary(path) ->
            if internal_host?(host) do
              normalize_path_with_parts(path, query, fragment)
            end

          _ ->
            nil
        end
    end
  end

  defp normalize_internal_url(_url), do: nil

  defp normalize_path(path) when is_binary(path) do
    case URI.parse(path) do
      %URI{path: parsed_path, query: query, fragment: fragment} when is_binary(parsed_path) ->
        normalize_path_with_parts(parsed_path, query, fragment)

      _ ->
        nil
    end
  end

  defp normalize_path(_path), do: nil

  defp normalize_path_with_parts(path, query, fragment) when is_binary(path) do
    normalized_path =
      path
      |> String.trim()
      |> case do
        "" -> "/"
        "/" <> _ = absolute -> absolute
        relative -> "/" <> relative
      end

    query_part = if is_binary(query) and query != "", do: "?" <> query, else: ""
    fragment_part = if is_binary(fragment) and fragment != "", do: "#" <> fragment, else: ""

    normalized_path <> query_part <> fragment_part
  end

  defp normalize_path_with_parts(_path, _query, _fragment), do: nil

  defp internal_host?(host) when is_binary(host) do
    canonical_host =
      :agent_jido
      |> Application.get_env(:canonical_host, "agentjido.xyz")
      |> to_string()
      |> String.downcase()

    host_down = String.downcase(host)

    host_down in [canonical_host, "www." <> canonical_host, "localhost", "127.0.0.1"]
  end

  defp internal_host?(_host), do: false

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

  defp normalize_uuid(value) when is_binary(value) do
    case Ecto.UUID.cast(value) do
      {:ok, uuid} ->
        uuid

      :error ->
        case Ecto.UUID.load(value) do
          {:ok, uuid} -> uuid
          :error -> nil
        end
    end
  end

  defp normalize_uuid(_value), do: nil

  defp normalize_metadata(metadata) when is_map(metadata), do: metadata
  defp normalize_metadata(_metadata), do: %{}

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
