defmodule AgentJido.Blog.EditorBlocks do
  @moduledoc """
  Converts between legacy HTML bodies and Editor.js block payloads.
  """

  alias Phoenix.HTML

  @type editor_body :: map()

  @spec html_to_editor_body(String.t(), keyword()) :: editor_body()
  def html_to_editor_body(html, opts \\ [])

  def html_to_editor_body(html, opts) when is_binary(html) do
    blocks =
      html
      |> html_to_blocks()
      |> case do
        [] -> [%{"type" => "paragraph", "data" => %{"text" => ""}}]
        found -> found
      end

    %{
      "raw_html" => html,
      "legacy_source_path" => Keyword.get(opts, :source_path),
      "legacy_post_type" => Keyword.get(opts, :post_type),
      "legacy_audience" => Keyword.get(opts, :audience),
      "legacy_journey_stage" => Keyword.get(opts, :journey_stage),
      "legacy_content_intent" => Keyword.get(opts, :content_intent),
      "legacy_capability_theme" => Keyword.get(opts, :capability_theme),
      "legacy_evidence_surface" => Keyword.get(opts, :evidence_surface),
      "legacy_related_docs" => Keyword.get(opts, :related_docs, []),
      "legacy_related_posts" => Keyword.get(opts, :related_posts, []),
      "legacy_is_livebook" => Keyword.get(opts, :is_livebook, false),
      "blocks" => blocks
    }
  end

  def html_to_editor_body(_html, opts), do: html_to_editor_body("", opts)

  @spec body_to_html(editor_body() | nil) :: String.t()
  def body_to_html(%{"raw_html" => html}) when is_binary(html) and html != "", do: html

  def body_to_html(%{raw_html: html}) when is_binary(html) and html != "", do: html

  def body_to_html(%{"blocks" => blocks}) when is_list(blocks) do
    Enum.map_join(blocks, "\n", &block_to_html/1)
  end

  def body_to_html(%{blocks: blocks}) when is_list(blocks) do
    Enum.map_join(blocks, "\n", &block_to_html/1)
  end

  def body_to_html(_), do: ""

  @spec body_to_text(editor_body() | nil) :: String.t()
  def body_to_text(body) do
    body
    |> body_to_html()
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

  defp html_to_blocks(html) when is_binary(html) do
    case Floki.parse_fragment(html) do
      {:ok, nodes} -> Enum.flat_map(nodes, &node_to_blocks/1)
      _ -> []
    end
  end

  defp node_to_blocks(node) when is_binary(node) do
    node
    |> String.trim()
    |> case do
      "" -> []
      text -> [%{"type" => "paragraph", "data" => %{"text" => text}}]
    end
  end

  defp node_to_blocks({"p", _attrs, children}) do
    text = children_to_html(children)

    if String.trim(text) == "" do
      []
    else
      [%{"type" => "paragraph", "data" => %{"text" => text}}]
    end
  end

  defp node_to_blocks({tag, _attrs, children}) when tag in ["h1", "h2", "h3", "h4", "h5", "h6"] do
    level = tag |> String.trim_leading("h") |> String.to_integer()
    text = children_to_html(children)

    if String.trim(text) == "" do
      []
    else
      [%{"type" => "header", "data" => %{"text" => text, "level" => level}}]
    end
  end

  defp node_to_blocks({"ul", _attrs, children}) do
    list_block("unordered", children)
  end

  defp node_to_blocks({"ol", _attrs, children}) do
    list_block("ordered", children)
  end

  defp node_to_blocks({"pre", _attrs, children}) do
    code =
      children
      |> Floki.raw_html()
      |> String.replace(~r/^<code[^>]*>/i, "")
      |> String.replace(~r/<\/code>$/i, "")

    if String.trim(code) == "" do
      []
    else
      [%{"type" => "code", "data" => %{"code" => code}}]
    end
  end

  defp node_to_blocks({"blockquote", _attrs, children}) do
    text = children_to_html(children)

    if String.trim(text) == "" do
      []
    else
      [%{"type" => "quote", "data" => %{"text" => text, "caption" => ""}}]
    end
  end

  defp node_to_blocks({"hr", _attrs, _children}) do
    [%{"type" => "delimiter", "data" => %{}}]
  end

  defp node_to_blocks({"img", attrs, _children}) do
    attrs_map = Map.new(attrs)

    src = Map.get(attrs_map, "src", "")
    caption = Map.get(attrs_map, "alt", "")

    if String.trim(src) == "" do
      []
    else
      [%{"type" => "image", "data" => %{"url" => src, "caption" => caption}}]
    end
  end

  defp node_to_blocks({_tag, _attrs, children}) do
    case Enum.flat_map(children, &node_to_blocks/1) do
      [] ->
        text = children_to_html(children)

        if String.trim(text) == "" do
          []
        else
          [%{"type" => "paragraph", "data" => %{"text" => text}}]
        end

      blocks ->
        blocks
    end
  end

  defp list_block(style, children) do
    items =
      children
      |> Enum.filter(&match?({"li", _, _}, &1))
      |> Enum.map(fn {"li", _li_attrs, li_children} ->
        li_children
        |> children_to_html()
        |> String.trim()
      end)
      |> Enum.reject(&(&1 == ""))

    if items == [] do
      []
    else
      [%{"type" => "list", "data" => %{"style" => style, "items" => items}}]
    end
  end

  defp children_to_html(children) when is_list(children), do: Floki.raw_html(children)
  defp children_to_html(_children), do: ""

  defp block_to_html(%{"type" => "paragraph", "data" => %{"text" => text}}), do: "<p>#{text}</p>"

  defp block_to_html(%{"type" => "header", "data" => %{"text" => text, "level" => level}}) do
    normalized_level =
      case level do
        value when is_integer(value) and value in 1..6 ->
          value

        value when is_binary(value) ->
          case Integer.parse(value) do
            {parsed, ""} when parsed in 1..6 -> parsed
            _ -> 2
          end

        _ ->
          2
      end

    "<h#{normalized_level}>#{text}</h#{normalized_level}>"
  end

  defp block_to_html(%{"type" => "list", "data" => %{"style" => style, "items" => items}})
       when is_list(items) do
    {open_tag, close_tag} = if style == "ordered", do: {"<ol>", "</ol>"}, else: {"<ul>", "</ul>"}

    rendered_items =
      Enum.map_join(items, "", fn
        %{"content" => content} -> "<li>#{content}</li>"
        content when is_binary(content) -> "<li>#{content}</li>"
        _ -> ""
      end)

    open_tag <> rendered_items <> close_tag
  end

  defp block_to_html(%{"type" => "quote", "data" => %{"text" => text}}), do: "<blockquote><p>#{text}</p></blockquote>"

  defp block_to_html(%{"type" => "code", "data" => %{"code" => code} = data}) do
    language = Map.get(data, "language") || Map.get(data, "lang")
    highlight_code_block(code, language)
  end

  defp block_to_html(%{"type" => "delimiter"}), do: "<hr />"

  defp block_to_html(%{"type" => "image", "data" => %{"url" => url, "caption" => caption}})
       when is_binary(url) and url != "" do
    escaped_caption = if is_binary(caption), do: caption, else: ""
    "<figure><img src=\"#{url}\" alt=\"#{escaped_caption}\" /><figcaption>#{escaped_caption}</figcaption></figure>"
  end

  defp block_to_html(%{"type" => "embed", "data" => %{"source" => source}})
       when is_binary(source) do
    "<p><a href=\"#{source}\">#{source}</a></p>"
  end

  defp block_to_html(_unsupported), do: ""

  defp highlight_code_block(code, language) when is_binary(code) do
    opts =
      case code_lexer(language) do
        nil -> []
        lexer -> [lexer: lexer]
      end

    Makeup.highlight(code, opts)
  rescue
    _ ->
      escaped = code |> HTML.html_escape() |> HTML.safe_to_string()
      "<pre><code>#{escaped}</code></pre>"
  end

  defp highlight_code_block(_code, _language), do: "<pre><code></code></pre>"

  defp code_lexer(language) when is_binary(language) do
    case String.downcase(String.trim(language)) do
      "elixir" -> Makeup.Lexers.ElixirLexer
      "ex" -> Makeup.Lexers.ElixirLexer
      "exs" -> Makeup.Lexers.ElixirLexer
      "javascript" -> Makeup.Lexers.JsLexer
      "js" -> Makeup.Lexers.JsLexer
      "html" -> Makeup.Lexers.HTMLLexer
      _ -> nil
    end
  end

  defp code_lexer(_), do: nil
end
