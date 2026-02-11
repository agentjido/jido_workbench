defmodule AgentJido.Documentation.Document do
  @moduledoc """
  Represents a documentation document parsed from a Markdown or Livebook file.

  Uses Zoi-validated schemas with rich metadata for validation, freshness
  tracking, SEO, quality assessment, and Livebook integration.

  ## Fields

  - `id` - Unique identifier derived from path (e.g., "chat-response")
  - `title` - Document title from frontmatter
  - `description` - Optional description
  - `category` - Category atom (e.g., :cookbook, :docs)
  - `tags` - List of tag atoms for filtering
  - `order` - Sort order within category (default: 9999)
  - `body` - Parsed HTML content
  - `path` - URL path relative to documentation root
  - `source_path` - Original file path on disk
  - `is_livebook` - Whether this is a .livemd file
  - `github_url` - Link to view on GitHub
  - `livebook_url` - Link to run in Livebook
  - `menu_path` - List of path segments for menu hierarchy
  - `draft` - If true, document is hidden from listings
  - `in_menu` - If false, document is hidden from navigation menu
  - `menu_label` - Override title in menu display
  - `doc_type` - Document type (:guide, :reference, :tutorial, :explanation, :cookbook)
  - `audience` - Target audience (:beginner, :intermediate, :advanced)
  - `word_count` - Computed word count
  - `reading_time_minutes` - Computed reading time
  - `related_docs` - List of related document IDs
  - `related_posts` - List of related blog post IDs
  - `validation` - Nested validation metadata
  - `freshness` - Nested freshness tracking metadata
  - `seo` - Nested SEO metadata
  - `quality` - Nested quality assessment metadata
  - `livebook` - Nested Livebook integration metadata
  """

  @github_repo "https://github.com/agentjido/agentjido_xyz"

  @schema Zoi.struct(
            __MODULE__,
            %{
              id: Zoi.string(description: "Unique identifier derived from path"),
              title: Zoi.string(description: "Document title from frontmatter"),
              description: Zoi.string(description: "Optional description") |> Zoi.optional(),
              category: Zoi.atom(description: "Category atom (e.g., :docs, :cookbook)"),
              tags: Zoi.any(description: "List of tag atoms for filtering") |> Zoi.default([]),
              order: Zoi.integer(description: "Sort order within category") |> Zoi.default(9999),
              body: Zoi.string(description: "Rendered HTML content") |> Zoi.default(""),
              path:
                Zoi.string(description: "URL path relative to documentation root")
                |> Zoi.default(""),
              source_path: Zoi.string(description: "Absolute file path on disk") |> Zoi.default(""),
              is_livebook:
                Zoi.boolean(description: "Whether this is a .livemd file")
                |> Zoi.default(false),
              github_url: Zoi.string(description: "Link to view on GitHub") |> Zoi.default(""),
              livebook_url: Zoi.string(description: "Link to run in Livebook") |> Zoi.optional(),
              menu_path:
                Zoi.any(description: "List of path segments for menu hierarchy")
                |> Zoi.default([]),
              draft:
                Zoi.boolean(description: "If true, document is hidden from listings")
                |> Zoi.default(false),
              in_menu:
                Zoi.boolean(description: "If false, document is hidden from navigation menu")
                |> Zoi.default(true),
              menu_label: Zoi.string(description: "Override title in menu display") |> Zoi.optional(),
              doc_type:
                Zoi.atom(description: "Document type (:guide, :reference, :tutorial, :explanation, :cookbook)")
                |> Zoi.default(:guide),
              audience:
                Zoi.atom(description: "Target audience (:beginner, :intermediate, :advanced)")
                |> Zoi.default(:beginner),
              word_count: Zoi.integer(description: "Computed word count") |> Zoi.default(0),
              reading_time_minutes: Zoi.integer(description: "Computed reading time in minutes") |> Zoi.default(0),
              related_docs: Zoi.any(description: "List of related document IDs") |> Zoi.default([]),
              related_posts: Zoi.any(description: "List of related blog post IDs") |> Zoi.default([]),
              validation:
                Zoi.map(
                  %{
                    repos: Zoi.any(description: "Referenced repos") |> Zoi.default([]),
                    source_modules: Zoi.any(description: "Referenced source modules") |> Zoi.default([]),
                    source_files: Zoi.any(description: "Referenced source files") |> Zoi.default([]),
                    ecosystem_packages: Zoi.any(description: "Referenced ecosystem packages") |> Zoi.default([]),
                    min_elixir_version:
                      Zoi.string(description: "Minimum Elixir version required")
                      |> Zoi.optional(),
                    min_package_versions: Zoi.any(description: "Minimum package versions") |> Zoi.default([]),
                    claims: Zoi.any(description: "Factual claims to verify") |> Zoi.default([]),
                    feature_flags: Zoi.any(description: "Required feature flags") |> Zoi.default([])
                  },
                  description: "Validation metadata"
                )
                |> Zoi.default(%{}),
              freshness:
                Zoi.map(
                  %{
                    content_hash: Zoi.string(description: "SHA256 hash of content") |> Zoi.default(""),
                    stale_after_days:
                      Zoi.integer(description: "Days before content is considered stale")
                      |> Zoi.default(120),
                    last_refreshed_at: Zoi.string(description: "ISO8601 date of last refresh") |> Zoi.optional(),
                    last_validated_at:
                      Zoi.string(description: "ISO8601 date of last validation")
                      |> Zoi.optional(),
                    validation_status: Zoi.atom(description: "Current validation status") |> Zoi.default(:unknown),
                    validated_by: Zoi.string(description: "Who last validated") |> Zoi.optional(),
                    validation_notes: Zoi.string(description: "Notes from last validation") |> Zoi.optional()
                  },
                  description: "Freshness tracking metadata"
                )
                |> Zoi.default(%{}),
              seo:
                Zoi.map(
                  %{
                    canonical_url: Zoi.string(description: "Canonical URL") |> Zoi.optional(),
                    og_title: Zoi.string(description: "Open Graph title") |> Zoi.optional(),
                    og_description: Zoi.string(description: "Open Graph description") |> Zoi.optional(),
                    og_image: Zoi.string(description: "Open Graph image URL") |> Zoi.optional(),
                    keywords: Zoi.any(description: "SEO keywords") |> Zoi.default([]),
                    noindex:
                      Zoi.boolean(description: "Whether to noindex this page")
                      |> Zoi.default(false)
                  },
                  description: "SEO metadata"
                )
                |> Zoi.default(%{}),
              quality:
                Zoi.map(
                  %{
                    reviewed_by: Zoi.any(description: "List of reviewers") |> Zoi.default([]),
                    reviewed_at: Zoi.string(description: "ISO8601 date of last review") |> Zoi.optional(),
                    confidence: Zoi.number(description: "Confidence score 0.0-1.0") |> Zoi.default(0.7),
                    examples_present:
                      Zoi.boolean(description: "Whether examples are present")
                      |> Zoi.default(false),
                    tested_examples:
                      Zoi.boolean(description: "Whether examples have been tested")
                      |> Zoi.default(false)
                  },
                  description: "Quality assessment metadata"
                )
                |> Zoi.default(%{}),
              livebook:
                Zoi.map(
                  %{
                    runnable:
                      Zoi.boolean(description: "Whether livebook is runnable")
                      |> Zoi.default(false),
                    elixir_version: Zoi.string(description: "Required Elixir version") |> Zoi.optional(),
                    mix_deps: Zoi.any(description: "Required Mix dependencies") |> Zoi.default([]),
                    required_env_vars: Zoi.any(description: "Required environment variables") |> Zoi.default([]),
                    required_services: Zoi.any(description: "Required external services") |> Zoi.default([]),
                    requires_network:
                      Zoi.boolean(description: "Whether network access is required")
                      |> Zoi.default(false),
                    setup_instructions: Zoi.string(description: "Setup instructions") |> Zoi.optional()
                  },
                  description: "Livebook integration metadata"
                )
                |> Zoi.default(%{})
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  def schema, do: @schema

  @doc """
  Builds a document struct from a file.

  - filename: The full path to the file
  - attrs: Map of metadata attributes from the markdown frontmatter
  - body: The parsed content of the file
  """
  def build(filename, attrs, body) do
    order = Map.get(attrs, :order, 9999)

    full_app_path = Application.app_dir(:agent_jido)
    source_path = filename
    app_relative_path = String.replace(filename, full_app_path, "")

    doc_root = "/priv/documentation"
    path = String.replace(app_relative_path, doc_root, "")

    is_livebook = String.ends_with?(filename, ".livemd")

    path = normalize_path(path)
    id = derive_id(path)
    menu_path = derive_menu_path(path)

    github_url = build_github_url(doc_root, path, is_livebook)
    livebook_url = build_livebook_url(github_url, is_livebook)

    word_count = compute_word_count(body)
    reading_time_minutes = max(1, div(word_count, 200))

    content_hash =
      :crypto.hash(:sha256, "#{filename}\n#{body}") |> Base.encode16(case: :lower)

    user_freshness = Map.get(attrs, :freshness, %{})

    computed_freshness =
      Map.merge(%{content_hash: content_hash}, user_freshness)

    attrs =
      attrs
      |> Map.put(:id, id)
      |> Map.put(:body, body)
      |> Map.put(:path, path)
      |> Map.put(:source_path, source_path)
      |> Map.put(:is_livebook, is_livebook)
      |> Map.put(:github_url, github_url)
      |> Map.put(:menu_path, menu_path)
      |> Map.put(:order, order)
      |> Map.put(:word_count, word_count)
      |> Map.put(:reading_time_minutes, reading_time_minutes)
      |> Map.put(:freshness, computed_freshness)

    attrs =
      if livebook_url, do: Map.put(attrs, :livebook_url, livebook_url), else: attrs

    case Zoi.parse(@schema, attrs) do
      {:ok, doc} -> doc
      {:error, errors} -> raise "Invalid document #{id}: #{inspect(errors)}"
    end
  end

  defp compute_word_count(html) do
    html
    |> String.replace(~r/<[^>]+>/, " ")
    |> String.split(~r/\s+/, trim: true)
    |> length()
  end

  defp normalize_path(path) do
    if String.ends_with?(path, "/index.md") or String.ends_with?(path, "/index.livemd") do
      String.replace(path, ~r{/index\.(md|livemd)$}, "")
    else
      String.replace(path, ~r{\.(md|livemd)$}, "")
    end
  end

  defp derive_id(path) do
    path
    |> String.trim_leading("/")
    |> String.split("/", parts: 2)
    |> case do
      [_category, rest] -> rest
      [only] -> only
      [] -> "root"
    end
    |> String.replace("/", "-")
    |> case do
      "" -> "index"
      id -> id
    end
  end

  defp derive_menu_path(path) do
    path
    |> String.trim_leading("/")
    |> String.split("/")
    |> Enum.filter(&(&1 != "index" and &1 != ""))
  end

  defp build_github_url(doc_root, path, true = _is_livebook) do
    "#{@github_repo}/blob/main#{doc_root}#{path}.livemd"
  end

  defp build_github_url(doc_root, path, false = _is_livebook) do
    "#{@github_repo}/blob/main#{doc_root}#{path}.md"
  end

  defp build_livebook_url(github_url, true = _is_livebook) do
    "https://livebook.dev/run?url=#{github_url}"
  end

  defp build_livebook_url(_github_url, false = _is_livebook), do: nil
end
