defmodule AgentJido.Documentation.LivebookParser do
  @moduledoc """
  Custom parser for NimblePublisher that handles frontmatter in a Livebook-compatible way.

  This parser supports two formats:

  1. Standard NimblePublisher format for .md files:
     ```
     %{
       title: "Document Title",
       ...
     }
     ---
     # Content
     ```

  2. Simple HTML comment format for .livemd files:
     ```
     <!-- %{
       title: "Document Title",
       description: "Document description",
       category: :category,
       order: 1,
       tags: [:tag1, :tag2]
     } -->

     # Content
     ```

  The parser validates frontmatter at compile time and provides clear error messages.

  ## Supported Frontmatter Fields

  Required:
  - `title` - Document title (string)
  - `category` - Category atom (e.g., :cookbook, :docs)

  Optional:
  - `description` - Short description (string)
  - `order` - Sort order within category (integer, default: 9999)
  - `tags` - List of tag atoms (default: [])
  - `draft` - Hide from all listings (boolean, default: false)
  - `in_menu` - Show in navigation menu (boolean, default: true)
  - `menu_label` - Override title in menu (string)
  """

  @frontmatter_separator ~r/^---\s*$/m
  @html_comment_pattern ~r/\A\s*<!--\s*(%{.*?})\s*-->/s

  @doc """
  Parses the content of a file and extracts metadata and body.

  ## Parameters

  - path: The file path
  - contents: The file contents

  ## Returns

  A tuple `{attrs, body}` where:
  - attrs: Map of metadata attributes (normalized and validated)
  - body: The document body

  ## Raises

  `ArgumentError` if frontmatter is missing, malformed, or missing required fields.
  """
  def parse(path, contents) do
    {raw_attrs, body} =
      if String.ends_with?(path, ".livemd") do
        parse_livebook(path, contents)
      else
        parse_markdown(path, contents)
      end

    attrs = normalize_and_validate!(path, raw_attrs)
    {attrs, body}
  end

  @doc """
  Parse standard Markdown files with frontmatter.
  """
  def parse_markdown(path, contents) do
    case Regex.split(@frontmatter_separator, contents, parts: 2) do
      [frontmatter, body] ->
        attrs = parse_frontmatter!(path, frontmatter)
        {attrs, String.trim_leading(body)}

      [_only_body] ->
        raise ArgumentError,
              "Missing frontmatter in documentation file #{inspect(path)}. " <>
                "Expected an Elixir map followed by a line with `---`."
    end
  end

  @doc """
  Parse Livebook files with frontmatter in HTML comments.
  """
  def parse_livebook(path, contents) do
    case Regex.run(@html_comment_pattern, contents) do
      [full_match, attrs_str] ->
        attrs = parse_frontmatter!(path, attrs_str)
        body = String.replace(contents, full_match, "", global: false)
        {attrs, String.trim_leading(body)}

      nil ->
        case Regex.split(@frontmatter_separator, contents, parts: 2) do
          [frontmatter, body] ->
            attrs = parse_frontmatter!(path, frontmatter)
            {attrs, String.trim_leading(body)}

          [_only_body] ->
            raise ArgumentError,
                  "Missing frontmatter in Livebook file #{inspect(path)}. " <>
                    "Expected an Elixir map in HTML comments (<!-- %{...} -->) " <>
                    "or followed by a line with `---`."
        end
    end
  end

  defp parse_frontmatter!(path, frontmatter_str) do
    trimmed = String.trim(frontmatter_str)

    case Code.string_to_quoted(trimmed, file: path) do
      {:ok, ast} ->
        ensure_literal_map!(path, ast)

      {:error, {line, error, token}} ->
        raise ArgumentError,
              "Invalid frontmatter syntax in #{inspect(path)} at line #{line}: " <>
                "#{error}#{token}"
    end
  end

  defp ensure_literal_map!(path, {:%{}, _meta, _pairs} = ast) do
    try do
      {map, _bindings} = Code.eval_quoted(ast)
      map
    rescue
      e ->
        raise ArgumentError,
              "Failed to evaluate frontmatter in #{inspect(path)}: #{Exception.message(e)}"
    end
  end

  defp ensure_literal_map!(path, _other) do
    raise ArgumentError,
          "Frontmatter in #{inspect(path)} must be a map literal (e.g., %{title: \"...\"})"
  end

  defp normalize_and_validate!(path, attrs) when is_map(attrs) do
    attrs
    |> Map.put_new(:order, 9999)
    |> Map.put_new(:tags, [])
    |> Map.put_new(:draft, false)
    |> Map.put_new(:in_menu, true)
    |> validate_required!(path, [:title, :category])
    |> validate_types!(path)
  end

  defp validate_required!(attrs, path, required_keys) do
    missing = Enum.filter(required_keys, &(!Map.has_key?(attrs, &1)))

    if missing != [] do
      raise ArgumentError,
            "Missing required frontmatter keys in #{inspect(path)}: #{inspect(missing)}"
    end

    attrs
  end

  defp validate_types!(attrs, path) do
    validations = [
      {:title, &is_binary/1, "must be a string"},
      {:category, &is_atom/1, "must be an atom"},
      {:order, &is_integer/1, "must be an integer"},
      {:tags, &is_list/1, "must be a list"},
      {:draft, &is_boolean/1, "must be a boolean"},
      {:in_menu, &is_boolean/1, "must be a boolean"}
    ]

    Enum.each(validations, fn {key, validator, message} ->
      if Map.has_key?(attrs, key) do
        value = Map.get(attrs, key)

        unless validator.(value) do
          raise ArgumentError,
                "Invalid frontmatter in #{inspect(path)}: #{key} #{message}, got: #{inspect(value)}"
        end
      end
    end)

    if Map.has_key?(attrs, :menu_label) do
      unless is_binary(attrs.menu_label) do
        raise ArgumentError,
              "Invalid frontmatter in #{inspect(path)}: menu_label must be a string"
      end
    end

    attrs
  end
end
