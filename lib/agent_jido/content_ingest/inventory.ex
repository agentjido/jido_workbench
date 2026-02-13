defmodule AgentJido.ContentIngest.Inventory do
  @moduledoc """
  Builds a normalized local content inventory for Arcana ingestion.
  """

  alias AgentJido.Blog
  alias AgentJido.ContentIngest.Source
  alias AgentJido.Ecosystem
  alias AgentJido.Pages

  @managed_by "agent_jido.content_ingest.local/v1"

  @doc_collections %{
    docs: {"site_docs", "AgentJido documentation pages"},
    blog: {"site_blog", "AgentJido blog posts"},
    ecosystem: {"site_ecosystem", "AgentJido ecosystem package pages"}
  }

  @valid_scopes Map.keys(@doc_collections)

  @doc """
  Builds local content sources.

  ## Options

    * `:only` - Scope list from `[:docs, :blog, :ecosystem]`

  """
  @spec build(keyword()) :: [Source.t()]
  def build(opts \\ []) do
    scopes = normalize_scopes(Keyword.get(opts, :only))

    []
    |> maybe_add_docs(scopes)
    |> maybe_add_blog(scopes)
    |> maybe_add_ecosystem(scopes)
  end

  @doc """
  Stable managed marker written to Arcana document metadata.
  """
  @spec managed_by() :: String.t()
  def managed_by, do: @managed_by

  @doc """
  Valid ingestion scopes.
  """
  @spec valid_scopes() :: [atom()]
  def valid_scopes, do: @valid_scopes

  defp maybe_add_docs(acc, scopes) do
    if :docs in scopes, do: acc ++ build_docs(), else: acc
  end

  defp maybe_add_blog(acc, scopes) do
    if :blog in scopes, do: acc ++ build_blog(), else: acc
  end

  defp maybe_add_ecosystem(acc, scopes) do
    if :ecosystem in scopes, do: acc ++ build_ecosystem(), else: acc
  end

  defp build_docs do
    {collection, description} = @doc_collections.docs

    for doc <- Pages.all_pages() do
      body_text = html_to_text(doc.body)

      metadata =
        %{
          "managed_by" => @managed_by,
          "source_type" => "documentation",
          "id" => doc.id,
          "title" => doc.title,
          "description" => doc.description,
          "path" => doc.path,
          "url" => doc.path,
          "source_path" => doc.source_path,
          "category" => to_string(doc.category),
          "tags" => Enum.map(doc.tags || [], &to_string/1)
        }
        |> with_content_hash(hash_payload(doc.title, doc.description, doc.path, body_text, doc.tags))

      %Source{
        source_id: "docs:#{doc.path}",
        collection: collection,
        collection_description: description,
        text: compose_text([doc.title, doc.description, doc.path, Enum.join(doc.tags || [], " "), body_text]),
        metadata: metadata
      }
    end
  end

  defp build_blog do
    {collection, description} = @doc_collections.blog

    for post <- Blog.all_posts() do
      body_text = html_to_text(post.body)
      blog_url = "/blog/#{post.id}"

      metadata =
        %{
          "managed_by" => @managed_by,
          "source_type" => "blog",
          "id" => post.id,
          "title" => post.title,
          "description" => post.description,
          "url" => blog_url,
          "source_path" => post.source_path,
          "post_type" => to_string(post.post_type),
          "date" => Date.to_iso8601(post.date),
          "tags" => Enum.map(post.tags || [], &to_string/1)
        }
        |> with_content_hash(hash_payload(post.title, post.description, post.id, body_text, post.tags))

      %Source{
        source_id: "blog:#{post.id}",
        collection: collection,
        collection_description: description,
        text:
          compose_text([
            post.title,
            post.description,
            blog_url,
            Enum.join(post.tags || [], " "),
            body_text
          ]),
        metadata: metadata
      }
    end
  end

  defp build_ecosystem do
    {collection, description} = @doc_collections.ecosystem

    for pkg <- Ecosystem.all_packages() do
      body_text = html_to_text(pkg.body)
      package_url = "/ecosystem##{pkg.id}"

      metadata =
        %{
          "managed_by" => @managed_by,
          "source_type" => "ecosystem",
          "id" => pkg.id,
          "name" => pkg.name,
          "title" => pkg.title,
          "tagline" => pkg.tagline,
          "description" => pkg.description,
          "version" => pkg.version,
          "category" => to_string(pkg.category),
          "tier" => pkg.tier,
          "url" => package_url,
          "source_path" => pkg.path,
          "ecosystem_deps" => pkg.ecosystem_deps || [],
          "tags" => Enum.map(pkg.tags || [], &to_string/1),
          "hex_url" => pkg.hex_url,
          "hexdocs_url" => pkg.hexdocs_url,
          "github_url" => pkg.github_url
        }
        |> with_content_hash(
          hash_payload(
            pkg.id,
            pkg.version,
            pkg.tagline,
            pkg.description,
            pkg.ecosystem_deps,
            pkg.tags,
            body_text
          )
        )

      %Source{
        source_id: "ecosystem:#{pkg.id}",
        collection: collection,
        collection_description: description,
        text:
          compose_text([
            pkg.title,
            pkg.tagline,
            pkg.description,
            package_url,
            Enum.join(pkg.key_features || [], "\n"),
            body_text
          ]),
        metadata: metadata
      }
    end
  end

  defp normalize_scopes(nil), do: @valid_scopes
  defp normalize_scopes([]), do: @valid_scopes

  defp normalize_scopes(scopes) when is_list(scopes) do
    scopes
    |> Enum.map(&normalize_scope/1)
    |> Enum.uniq()
  end

  defp normalize_scope(scope) when scope in @valid_scopes, do: scope

  defp normalize_scope(scope) when is_binary(scope) do
    case Enum.find(@valid_scopes, &(Atom.to_string(&1) == scope)) do
      nil ->
        raise ArgumentError,
              "invalid scope #{inspect(scope)}. Expected one of: #{inspect(@valid_scopes)}"

      valid ->
        valid
    end
  end

  defp normalize_scope(other) do
    raise ArgumentError,
          "invalid scope #{inspect(other)}. Expected one of: #{inspect(@valid_scopes)}"
  end

  defp hash_payload(parts) do
    payload = :erlang.term_to_binary(parts)
    :crypto.hash(:sha256, payload) |> Base.encode16(case: :lower)
  end

  defp hash_payload(a, b, c, d, e), do: hash_payload([a, b, c, d, e])
  defp hash_payload(a, b, c, d, e, f, g), do: hash_payload([a, b, c, d, e, f, g])

  defp with_content_hash(metadata, hash), do: Map.put(metadata, "content_hash", hash)

  defp compose_text(parts) do
    parts
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  defp html_to_text(nil), do: ""

  defp html_to_text(html) do
    html
    |> String.replace(~r/<\/(p|div|section|article|h[1-6]|li|ul|ol|br)>/i, "\n")
    |> String.replace(~r/<[^>]*>/, " ")
    |> String.replace("&nbsp;", " ")
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace(~r/[ \t]+/, " ")
    |> String.replace(~r/\n{3,}/, "\n\n")
    |> String.trim()
  end
end
