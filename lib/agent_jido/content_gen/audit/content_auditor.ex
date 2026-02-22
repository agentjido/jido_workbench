defmodule AgentJido.ContentGen.Audit.ContentAuditor do
  @moduledoc """
  Deep audit gates for generated content.
  """

  alias AgentJido.ContentGen.Audit.SourceIndex
  alias AgentJido.ContentGen.Contract
  alias AgentJido.Release.LinkAudit

  @placeholder_patterns [
    ~r/\bTODO\b/i,
    ~r/\bTBD\b/i,
    ~r/coming soon/i,
    ~r/content coming soon/i,
    ~r/lorem ipsum/i
  ]

  @module_fun_arity ~r/\b([A-Z][A-Za-z0-9_]*(?:\.[A-Z][A-Za-z0-9_]*)+)\.([a-z][A-Za-z0-9_!?]*)\/(\d+)\b/
  @local_defmodule ~r/\bdefmodule\s+([A-Z][A-Za-z0-9_.]+)\b/
  @internal_link ~r/\]\((\/[^)\s]+)\)/
  @cross_link_prefixes ["/build", "/training", "/ecosystem", "/docs"]

  @spec audit(struct(), map(), map(), keyword()) :: map()
  def audit(entry, target, candidate, opts \\ []) do
    source_index = Keyword.get(opts, :source_index, SourceIndex.build())
    route_patterns = Keyword.get(opts, :route_patterns, LinkAudit.route_patterns())
    planned_routes = Keyword.get(opts, :planned_routes, [])

    body = candidate.body_markdown || ""
    full_text = candidate.raw || body
    contract = Contract.contract(entry, target)

    errors =
      []
      |> append(check_placeholders(full_text))
      |> append(check_contract_required_sections(body, contract))
      |> append(check_contract_required_links(body, contract))
      |> append(check_contract_word_count(body, contract))
      |> append(check_contract_code_blocks(body, contract))
      |> append(check_contract_fun_refs(body, contract))
      |> append(check_module_refs(body, source_index))
      |> append(check_source_modules(body, entry))
      |> append(check_source_files(body, entry))
      |> append(check_internal_links(body, route_patterns, planned_routes))
      |> append(check_cross_links(body))

    warnings = []

    %{
      errors: errors,
      warnings: warnings,
      score: score(errors, warnings),
      summary: %{
        route: target.route,
        contract_profile: contract.profile,
        word_count: word_count(body),
        checked_module_refs: length(extract_module_refs(body)),
        checked_internal_links: length(extract_internal_links(body))
      }
    }
  end

  defp check_contract_required_sections(body, contract) do
    headings = extract_headings(body)

    contract.required_sections
    |> Enum.reduce([], fn section, acc ->
      normalized_required = normalize_heading(section)

      has_heading? =
        Enum.any?(headings, fn heading ->
          heading == normalized_required or
            String.starts_with?(heading, normalized_required <> ":") or
            String.starts_with?(heading, normalized_required <> " -")
        end)

      if has_heading? do
        acc
      else
        [
          %{
            code: :contract_missing_required_section,
            message: "missing required section heading: #{section}"
          }
          | acc
        ]
      end
    end)
    |> Enum.reverse()
  end

  defp check_contract_required_links(body, contract) do
    links = extract_internal_links(body)

    contract.required_links
    |> Enum.reduce([], fn required_link, acc ->
      required = normalize_link(required_link)

      has_link? =
        Enum.any?(links, fn link ->
          link == required or String.starts_with?(link, required <> "/")
        end)

      if has_link? do
        acc
      else
        [%{code: :contract_missing_required_link, message: "missing required internal link: #{required_link}"} | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp check_contract_word_count(body, contract) do
    words = word_count(body)

    cond do
      words < contract.min_words ->
        [
          %{
            code: :contract_word_count_below_min,
            message: "word count #{words} is below minimum #{contract.min_words}"
          }
        ]

      words > contract.max_words ->
        [
          %{
            code: :contract_word_count_above_max,
            message: "word count #{words} exceeds maximum #{contract.max_words}"
          }
        ]

      true ->
        []
    end
  end

  defp check_contract_code_blocks(body, contract) do
    code_blocks = code_block_count(body)

    if code_blocks < contract.minimum_code_blocks do
      [
        %{
          code: :contract_insufficient_code_blocks,
          message: "code blocks #{code_blocks} below required minimum #{contract.minimum_code_blocks}"
        }
      ]
    else
      []
    end
  end

  defp check_contract_fun_refs(body, contract) do
    fun_refs = body |> extract_module_refs() |> length()

    if fun_refs < contract.minimum_fun_refs do
      [
        %{
          code: :contract_insufficient_fun_refs,
          message: "module/function refs #{fun_refs} below required minimum #{contract.minimum_fun_refs}"
        }
      ]
    else
      []
    end
  end

  defp check_placeholders(text) do
    @placeholder_patterns
    |> Enum.filter(&(text =~ &1))
    |> Enum.map(fn pattern ->
      %{code: :placeholder_detected, message: "placeholder detected: #{inspect(pattern)}"}
    end)
  end

  defp check_module_refs(body, source_index) do
    local_modules = extract_local_modules(body)

    body
    |> extract_module_refs()
    |> Enum.reduce([], fn {module_name, function_name, arity}, acc ->
      if module_name in local_modules or SourceIndex.export_exists?(source_index, module_name, function_name, arity) do
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

  defp check_internal_links(body, route_patterns, planned_routes) do
    body
    |> extract_internal_links()
    |> Enum.reduce([], fn link, acc ->
      if link_valid?(link, route_patterns, planned_routes) do
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

  defp extract_local_modules(body) do
    Regex.scan(@local_defmodule, body)
    |> Enum.map(fn
      [_, module_name] -> module_name
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp extract_internal_links(body) do
    Regex.scan(@internal_link, body)
    |> Enum.map(fn [_, link] -> normalize_link(link) end)
    |> Enum.uniq()
  end

  defp extract_headings(body) do
    Regex.scan(~r/^\#{1,6}\s+(.+)$/m, body)
    |> Enum.map(fn
      [_, heading] -> normalize_heading(heading)
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp normalize_heading(heading) do
    heading
    |> to_string()
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
    |> String.downcase()
  end

  defp word_count(body) do
    cleaned =
      body
      |> String.replace(~r/```.*?```/s, " ")

    Regex.scan(~r/[A-Za-z0-9][A-Za-z0-9'_-]*/, cleaned)
    |> length()
  end

  defp code_block_count(body) do
    Regex.scan(~r/```[a-zA-Z0-9_-]*\n.*?```/s, body)
    |> length()
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

  defp link_valid?(link, route_patterns, planned_routes) do
    route_match? = Enum.any?(route_patterns, &route_matches?(link, &1))
    planned_route? = Enum.any?(planned_routes, &(normalize_link(&1) == normalize_link(link)))
    route_match? or planned_route?
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
