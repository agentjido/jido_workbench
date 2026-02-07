defmodule JidoWorkbench.Documentation.Document do
  @moduledoc """
  Represents a documentation document parsed from a Markdown or Livebook file.

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
  """

  @github_repo "https://github.com/agentjido/jido_workbench"

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          description: String.t() | nil,
          category: atom(),
          tags: [atom()],
          order: integer(),
          body: String.t(),
          path: String.t(),
          source_path: String.t(),
          is_livebook: boolean(),
          github_url: String.t(),
          livebook_url: String.t() | nil,
          menu_path: [String.t()],
          draft: boolean(),
          in_menu: boolean(),
          menu_label: String.t() | nil
        }

  @enforce_keys [:title, :category]
  defstruct [
    :id,
    :title,
    :body,
    :description,
    :category,
    :path,
    :source_path,
    :is_livebook,
    :github_url,
    :livebook_url,
    :menu_path,
    :menu_label,
    tags: [],
    order: 9999,
    draft: false,
    in_menu: true
  ]

  @doc """
  Builds a document struct from a file.

  - filename: The full path to the file
  - attrs: Map of metadata attributes from the markdown frontmatter
  - body: The parsed content of the file
  """
  def build(filename, attrs, body) do
    order = Map.get(attrs, :order, 9999)

    full_app_path = Application.app_dir(:jido_workbench)
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

    struct!(
      __MODULE__,
      [
        id: id,
        body: body,
        path: path,
        source_path: source_path,
        is_livebook: is_livebook,
        github_url: github_url,
        livebook_url: livebook_url,
        menu_path: menu_path,
        order: order,
        tags: Map.get(attrs, :tags, []),
        draft: Map.get(attrs, :draft, false),
        in_menu: Map.get(attrs, :in_menu, true),
        menu_label: Map.get(attrs, :menu_label)
      ] ++ Map.to_list(Map.drop(attrs, [:order, :tags, :draft, :in_menu, :menu_label]))
    )
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
