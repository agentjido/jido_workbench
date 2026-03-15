defmodule AgentJido.ContentGen.PathResolver do
  @moduledoc """
  Maps content-plan destination routes to deterministic page file paths.
  """

  alias AgentJido.ContentGen
  alias AgentJido.Pages

  @type target :: %{
          route: String.t(),
          target_path: String.t(),
          read_path: String.t(),
          format: :md | :livemd,
          exists?: boolean(),
          existing_path: String.t() | nil,
          conversion_source_path: String.t() | nil,
          non_file_backed?: boolean()
        }

  @spec resolve(struct(), keyword()) :: {:ok, target()} | {:skip, :skipped_non_file_target, map()}
  def resolve(entry, opts \\ []) do
    route = ContentGen.normalize_route(entry.destination_route)

    if ContentGen.non_file_backed_route?(route) do
      {:skip, :skipped_non_file_target, %{id: entry.id, route: route}}
    else
      page_index = Keyword.get(opts, :page_index, page_index())
      docs_format = Keyword.get(opts, :docs_format, :tag)
      existing_path = normalize_existing_path(Map.get(page_index, route))
      format = format_for(entry, existing_path, docs_format)
      target_path = target_path(entry, route, existing_path, format, docs_format)
      read_path = read_path_for(target_path, existing_path)
      conversion_source_path = conversion_source_path(entry, target_path, existing_path, docs_format)

      {:ok,
       %{
         route: route,
         target_path: target_path,
         read_path: read_path,
         format: format,
         exists?: File.exists?(read_path),
         existing_path: existing_path,
         conversion_source_path: conversion_source_path,
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

    if String.starts_with?(relative, "priv/pages/") do
      preferred_source_variant(relative)
    else
      case String.split(relative, "/priv/pages/", parts: 2) do
        [_prefix, page_suffix] when page_suffix != "" ->
          Path.join("priv/pages", page_suffix)
          |> preferred_source_variant()

        _other ->
          nil
      end
    end
  end

  defp preferred_source_variant(candidate) do
    alt = alternate_extension(candidate)

    cond do
      File.exists?(candidate) ->
        candidate

      is_binary(alt) and File.exists?(alt) ->
        alt

      true ->
        candidate
    end
  end

  defp alternate_extension(path) when is_binary(path) do
    cond do
      String.ends_with?(path, ".md") -> String.replace_suffix(path, ".md", ".livemd")
      String.ends_with?(path, ".livemd") -> String.replace_suffix(path, ".livemd", ".md")
      true -> nil
    end
  end

  defp format_for(entry, existing_path, docs_format) when is_binary(existing_path) do
    cond do
      docs_format == :livemd and entry.section == "docs" -> :livemd
      String.ends_with?(existing_path, ".livemd") -> :livemd
      true -> :md
    end
  end

  defp format_for(entry, nil, docs_format) do
    if docs_format == :livemd and entry.section == "docs" do
      :livemd
    else
      format_for_entry_tags(entry)
    end
  end

  defp format_for_entry_tags(entry) do
    tags = Map.get(entry, :tags, []) || []

    cond do
      entry.section == "docs" and :format_livebook in tags -> :livemd
      entry.section == "docs" and :format_markdown in tags -> :md
      true -> :md
    end
  end

  defp target_path(entry, route, existing_path, format, docs_format) do
    cond do
      docs_format == :livemd and entry.section == "docs" ->
        target_path_for_route(route, :livemd)

      is_binary(existing_path) ->
        existing_path

      true ->
        target_path_for_route(route, format)
    end
  end

  defp read_path_for(target_path, existing_path) when is_binary(target_path) do
    cond do
      File.exists?(target_path) ->
        target_path

      is_binary(existing_path) and File.exists?(existing_path) ->
        existing_path

      true ->
        target_path
    end
  end

  defp conversion_source_path(entry, target_path, existing_path, docs_format)
       when docs_format == :livemd and entry.section == "docs" and is_binary(existing_path) do
    cond do
      existing_path == target_path ->
        nil

      String.ends_with?(existing_path, ".md") and String.ends_with?(target_path, ".livemd") and File.exists?(existing_path) ->
        existing_path

      true ->
        nil
    end
  end

  defp conversion_source_path(_entry, _target_path, _existing_path, _docs_format), do: nil

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
