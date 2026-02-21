defmodule AgentJido.ContentGen.PathResolver do
  @moduledoc """
  Maps content-plan destination routes to deterministic page file paths.
  """

  alias AgentJido.ContentGen
  alias AgentJido.Pages

  @type target :: %{
          route: String.t(),
          target_path: String.t(),
          format: :md | :livemd,
          exists?: boolean(),
          existing_path: String.t() | nil,
          non_file_backed?: boolean()
        }

  @spec resolve(struct(), keyword()) :: {:ok, target()} | {:skip, :skipped_non_file_target, map()}
  def resolve(entry, opts \\ []) do
    route = ContentGen.normalize_route(entry.destination_route)

    if ContentGen.non_file_backed_route?(route) do
      {:skip, :skipped_non_file_target, %{id: entry.id, route: route}}
    else
      page_index = Keyword.get(opts, :page_index, page_index())
      existing_path = normalize_existing_path(Map.get(page_index, route))
      format = format_for(entry, existing_path)
      target_path = existing_path || target_path_for_route(route, format)

      {:ok,
       %{
         route: route,
         target_path: target_path,
         format: format,
         exists?: not is_nil(existing_path),
         existing_path: existing_path,
         non_file_backed?: false
       }}
    end
  end

  @spec page_index() :: %{String.t() => String.t()}
  def page_index do
    Pages.all_pages_including_drafts()
    |> Enum.reduce(%{}, fn page, acc ->
      case page.source_path do
        path when is_binary(path) and path != "" ->
          Map.put(acc, ContentGen.normalize_route(page.path), workspace_relative(path))

        _other ->
          acc
      end
    end)
  end

  defp workspace_relative(path) do
    cwd = File.cwd!()
    source_tree_path = source_tree_path(path, cwd)

    case source_tree_path || Path.relative_to(path, cwd) do
      relative ->
        if String.starts_with?(relative, "../"), do: path, else: relative
    end
  end

  defp normalize_existing_path(path) when is_binary(path), do: workspace_relative(path)
  defp normalize_existing_path(_path), do: nil

  defp source_tree_path(path, cwd) do
    relative = Path.relative_to(path, cwd)

    case String.split(relative, "/priv/pages/", parts: 2) do
      [_prefix, page_suffix] when page_suffix != "" ->
        source_path = Path.join("priv/pages", page_suffix)
        if File.exists?(source_path), do: source_path, else: nil

      _other ->
        nil
    end
  end

  defp format_for(_entry, existing_path) when is_binary(existing_path) do
    if String.ends_with?(existing_path, ".livemd"), do: :livemd, else: :md
  end

  defp format_for(entry, nil) do
    tags = Map.get(entry, :tags, []) || []

    cond do
      entry.section == "docs" and :format_livebook in tags -> :livemd
      entry.section == "docs" and :format_markdown in tags -> :md
      true -> :md
    end
  end

  @spec target_path_for_route(String.t(), :md | :livemd) :: String.t()
  def target_path_for_route(route, format) do
    ext = if format == :livemd, do: "livemd", else: "md"

    segments =
      route
      |> ContentGen.normalize_route()
      |> String.trim_leading("/")
      |> String.split("/", trim: true)

    case segments do
      [] ->
        Path.join(["priv", "pages", "index.#{ext}"])

      ["docs"] ->
        Path.join(["priv", "pages", "docs", "index.#{ext}"])

      ["docs", section] ->
        Path.join(["priv", "pages", "docs", "#{section}.#{ext}"])

      [single] ->
        Path.join(["priv", "pages", single, "index.#{ext}"])

      _many ->
        Path.join(["priv", "pages", Enum.join(segments, "/") <> ".#{ext}"])
    end
  end
end
