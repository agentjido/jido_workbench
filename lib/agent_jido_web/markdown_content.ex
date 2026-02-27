defmodule AgentJidoWeb.MarkdownContent do
  @moduledoc """
  Resolves markdown payloads for public site routes.
  """

  alias AgentJido.Blog
  alias AgentJido.Ecosystem
  alias AgentJido.Examples
  alias AgentJido.Pages
  alias AgentJidoWeb.MarkdownLinks

  @doc """
  Returns true when the request path is in the markdown-enabled public route set.
  """
  @spec eligible_public_path?(String.t()) :: boolean()
  def eligible_public_path?(path) when is_binary(path) do
    not excluded_prefix?(path) and allowed_prefix?(path)
  end

  @doc """
  Resolves a markdown payload for a request path.

  Returns `:no_match` when the path should fall through to normal routing.
  """
  @spec resolve(String.t(), String.t()) :: {:ok, String.t()} | :no_match
  def resolve(path, absolute_url) when is_binary(path) and is_binary(absolute_url) do
    case resolve_path(path) do
      {:ok, markdown} ->
        {:ok, markdown}

      {:fallback, title, summary} ->
        {:ok, fallback_markdown(title, absolute_url, summary)}

      :no_match ->
        :no_match
    end
  end

  defp resolve_path(path) do
    resolve_from_pages(path) ||
      resolve_from_blog(path) ||
      resolve_from_ecosystem(path) ||
      resolve_from_examples(path) ||
      resolve_misc(path) ||
      :no_match
  end

  defp resolve_from_pages(path) do
    case Pages.resolve_page_for_path(path) do
      {:ok, _page, :legacy} ->
        # Preserve existing redirect behavior for legacy routes.
        :no_match

      {:ok, page, _resolution} ->
        case read_source_markdown(map_get(page, :source_path)) do
          {:ok, markdown} ->
            {:ok, markdown}

          _other ->
            {:fallback, map_get(page, :title) || "Site Page", page_summary(page)}
        end

      :error ->
        nil
    end
  end

  defp resolve_from_blog("/blog") do
    {:fallback, "Engineering Blog", "Product updates, release notes, and practical guides for building reliable AI agents in Elixir and on the BEAM."}
  end

  defp resolve_from_blog("/blog/tags/" <> tag_path) do
    if valid_single_segment?(tag_path) do
      tag = String.trim(tag_path)

      try do
        posts = Blog.get_posts_by_tag!(tag)

        {:fallback, "Blog tag: #{tag}", "Posts tagged with #{tag}. Matching posts: #{length(posts)}."}
      rescue
        Blog.NotFoundError -> :no_match
      end
    else
      :no_match
    end
  end

  defp resolve_from_blog("/blog/" <> slug) do
    if valid_single_segment?(slug) do
      try do
        post = Blog.get_post_by_id!(slug)

        case read_source_markdown(map_get(post, :source_path)) do
          {:ok, markdown} ->
            {:ok, markdown}

          _other ->
            {:fallback, map_get(post, :title) || "Blog Post", post_summary(post)}
        end
      rescue
        Blog.NotFoundError -> :no_match
      end
    else
      :no_match
    end
  end

  defp resolve_from_blog(_path), do: nil

  defp resolve_from_ecosystem("/ecosystem") do
    {:fallback, "Jido Ecosystem", "Discover composable Jido packages across runtime core, AI orchestration, and production operations."}
  end

  defp resolve_from_ecosystem("/ecosystem/package-matrix") do
    {:fallback, "Jido Ecosystem Package Matrix", "Cross-package matrix view for capabilities, dependencies, and integrations."}
  end

  defp resolve_from_ecosystem("/ecosystem/" <> id_path) do
    if valid_single_segment?(id_path) do
      id = String.trim(id_path)

      case Ecosystem.get_public_package(id) do
        nil ->
          :no_match

        package ->
          case read_source_markdown(map_get(package, :path)) do
            {:ok, markdown} ->
              {:ok, markdown}

            _other ->
              {:fallback, map_get(package, :title) || "Ecosystem Package", package_summary(package)}
          end
      end
    else
      :no_match
    end
  end

  defp resolve_from_ecosystem(_path), do: nil

  defp resolve_from_examples("/examples") do
    {:fallback, "Jido Examples", "Interactive and production-oriented examples for agent workflows, orchestration, and reliability patterns."}
  end

  defp resolve_from_examples("/examples/" <> slug_path) do
    if valid_single_segment?(slug_path) do
      slug = String.trim(slug_path)

      case Examples.get_example(slug) do
        nil ->
          :no_match

        example ->
          case read_source_markdown(map_get(example, :source_path)) do
            {:ok, markdown} ->
              {:ok, markdown}

            _other ->
              {:fallback, map_get(example, :title) || "Example", example_summary(example)}
          end
      end
    else
      :no_match
    end
  end

  defp resolve_from_examples(_path), do: nil

  defp resolve_misc("/") do
    {:fallback, "Agent Jido",
     "A runtime for reliable multi-agent systems built on Elixir/OTP for fault isolation, concurrency, and production uptime."}
  end

  defp resolve_misc("/getting-started") do
    {:fallback, "Getting Started", "First-step onboarding route for building your first agent workflow with Jido."}
  end

  defp resolve_misc("/features") do
    {:fallback, "Jido Features", "Runtime capabilities, orchestration strategies, and ecosystem components for reliable multi-agent systems."}
  end

  defp resolve_misc(_path), do: nil

  defp fallback_markdown(title, absolute_url, summary) do
    markdown_new_url = MarkdownLinks.markdown_new_url(absolute_url)
    normalized_summary = normalize_summary(summary)

    """
    # #{title}

    Canonical URL: #{absolute_url}
    Markdown URL: #{markdown_new_url}

    #{normalized_summary}

    ---
    This markdown payload is generated from the rendered route when direct source markdown is not available.
    """
  end

  defp page_summary(page) do
    map_get(page, :description) || plain_text(map_get(page, :body))
  end

  defp post_summary(post) do
    map_get(post, :description) || plain_text(map_get(post, :body))
  end

  defp package_summary(package) do
    map_get(package, :tagline) || map_get(package, :description) || plain_text(map_get(package, :body))
  end

  defp example_summary(example) do
    map_get(example, :description) || plain_text(map_get(example, :body))
  end

  defp normalize_summary(summary) when is_binary(summary) do
    summary
    |> String.trim()
    |> case do
      "" -> "No additional summary available."
      value -> value
    end
  end

  defp normalize_summary(_summary), do: "No additional summary available."

  defp plain_text(value) when is_binary(value) do
    value
    |> String.replace(~r/<[^>]+>/, " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, 280)
  end

  defp plain_text(_value), do: ""

  defp read_source_markdown(path) when is_binary(path) and path != "" do
    if File.regular?(path) do
      File.read(path)
    else
      {:error, :missing}
    end
  end

  defp read_source_markdown(_path), do: {:error, :missing}

  defp map_get(map, key) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp valid_single_segment?(segment) when is_binary(segment) do
    trimmed = String.trim(segment)
    trimmed != "" and not String.contains?(trimmed, "/")
  end

  defp allowed_prefix?(path) do
    path == "/" or
      path == "/getting-started" or
      String.starts_with?(path, "/docs") or
      String.starts_with?(path, "/blog") or
      String.starts_with?(path, "/ecosystem") or
      String.starts_with?(path, "/features") or
      String.starts_with?(path, "/build") or
      String.starts_with?(path, "/community") or
      String.starts_with?(path, "/examples")
  end

  defp excluded_prefix?(path) do
    String.starts_with?(path, "/users") or
      String.starts_with?(path, "/dashboard") or
      String.starts_with?(path, "/dev") or
      String.starts_with?(path, "/assets") or
      String.starts_with?(path, "/og/") or
      path == "/feed" or
      path == "/sitemap.xml"
  end
end
