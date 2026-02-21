defmodule AgentJido.ContentGen.Audit.ContentAuditor do
  @moduledoc """
  Deep audit gates for generated content.
  """

  alias AgentJido.ContentGen.Audit.SourceIndex
  alias AgentJido.Release.LinkAudit

  @placeholder_patterns [
    ~r/\bTODO\b/i,
    ~r/\bTBD\b/i,
    ~r/coming soon/i,
    ~r/content coming soon/i,
    ~r/lorem ipsum/i
  ]

  @module_fun_arity ~r/\b([A-Z][A-Za-z0-9_.]+)\.([a-z][A-Za-z0-9_!?]*)\/(\d+)\b/
  @internal_link ~r/\]\((\/[^)\s]+)\)/
  @cross_link_prefixes ["/build", "/training", "/ecosystem", "/docs"]

  @spec audit(struct(), map(), map(), keyword()) :: map()
  def audit(entry, target, candidate, opts \\ []) do
    source_index = Keyword.get(opts, :source_index, SourceIndex.build())
    route_patterns = Keyword.get(opts, :route_patterns, LinkAudit.route_patterns())

    body = candidate.body_markdown || ""
    full_text = candidate.raw || body

    errors =
      []
      |> append(check_placeholders(full_text))
      |> append(check_module_refs(body, source_index))
      |> append(check_source_modules(body, entry))
      |> append(check_source_files(body, entry))
      |> append(check_internal_links(body, route_patterns))
      |> append(check_cross_links(body))

    warnings = []

    %{
      errors: errors,
      warnings: warnings,
      score: score(errors, warnings),
      summary: %{
        route: target.route,
        checked_module_refs: length(extract_module_refs(body)),
        checked_internal_links: length(extract_internal_links(body))
      }
    }
  end

  defp check_placeholders(text) do
    @placeholder_patterns
    |> Enum.filter(&(text =~ &1))
    |> Enum.map(fn pattern ->
      %{code: :placeholder_detected, message: "placeholder detected: #{inspect(pattern)}"}
    end)
  end

  defp check_module_refs(body, source_index) do
    body
    |> extract_module_refs()
    |> Enum.reduce([], fn {module_name, function_name, arity}, acc ->
      if SourceIndex.export_exists?(source_index, module_name, function_name, arity) do
        acc
      else
        [
          %{
            code: :unknown_module_export,
            message: "unknown module/function reference #{module_name}.#{function_name}/#{arity}"
          }
          | acc
        ]
      end
    end)
    |> Enum.reverse()
  end

  defp check_source_modules(body, entry) do
    entry
    |> Map.get(:source_modules, [])
    |> List.wrap()
    |> Enum.reduce([], fn source_module, acc ->
      source_module = to_string(source_module)

      if String.contains?(body, source_module) do
        acc
      else
        [%{code: :missing_source_module_mention, message: "source module not cited: #{source_module}"} | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp check_source_files(body, entry) do
    source_files = entry |> Map.get(:source_files, []) |> List.wrap() |> Enum.map(&to_string/1)

    if source_files == [] do
      []
    else
      cited? = Enum.any?(source_files, fn file -> String.contains?(body, file) or String.contains?(body, Path.basename(file)) end)

      if cited? do
        []
      else
        [%{code: :missing_source_file_citation, message: "no source file citation found in content"}]
      end
    end
  end

  defp check_internal_links(body, route_patterns) do
    body
    |> extract_internal_links()
    |> Enum.reduce([], fn link, acc ->
      if link_valid?(link, route_patterns) do
        acc
      else
        [%{code: :broken_internal_link, message: "internal link does not resolve: #{link}"} | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp check_cross_links(body) do
    links = extract_internal_links(body)

    if Enum.any?(links, fn link -> Enum.any?(@cross_link_prefixes, &String.starts_with?(link, &1)) end) do
      []
    else
      [%{code: :missing_cross_link_chain, message: "content does not include build/training/ecosystem/docs cross-link"}]
    end
  end

  defp extract_module_refs(body) do
    Regex.scan(@module_fun_arity, body)
    |> Enum.map(fn [_, mod, fun, arity] -> {mod, fun, String.to_integer(arity)} end)
    |> Enum.uniq()
  end

  defp extract_internal_links(body) do
    Regex.scan(@internal_link, body)
    |> Enum.map(fn [_, link] -> normalize_link(link) end)
    |> Enum.uniq()
  end

  defp normalize_link(link) do
    route =
      link
      |> String.trim()
      |> String.replace(~r/[?#].*$/, "")

    cond do
      route == "/" -> "/"
      String.ends_with?(route, "/") -> String.trim_trailing(route, "/")
      true -> route
    end
  end

  defp link_valid?(link, route_patterns) do
    Enum.any?(route_patterns, &route_matches?(link, &1))
  end

  defp route_matches?(path, route_pattern) do
    do_route_match?(segments(path), segments(route_pattern))
  end

  defp segments(path), do: path |> normalize_link() |> String.split("/", trim: true)

  defp do_route_match?(_path, [<<"*", _::binary>> | _rest]), do: true
  defp do_route_match?([], []), do: true
  defp do_route_match?(_path, []), do: false
  defp do_route_match?([], _route), do: false

  defp do_route_match?([path_segment | path_rest], [route_segment | route_rest]) do
    cond do
      String.starts_with?(route_segment, ":") -> do_route_match?(path_rest, route_rest)
      route_segment == path_segment -> do_route_match?(path_rest, route_rest)
      true -> false
    end
  end

  defp append(list, additions), do: list ++ additions

  defp score(errors, warnings) do
    raw = 1.0 - length(errors) * 0.15 - length(warnings) * 0.05
    max(0.0, Float.round(raw, 3))
  end
end
