defmodule AgentJido.ContentGen.Prompts do
  @moduledoc """
  Runtime prompt/template loader for content generation.

  Prompts are stored under `priv/prompts/content_gen/**` so they can be
  iterated in local development without recompiling modules.
  """

  alias AgentJido.ContentGen.Contract

  @default_prompt_root "priv/prompts/content_gen"
  @max_source_files 4
  @max_source_lines 100
  @max_brand_context_lines 100
  @max_manifesto_lines 140
  @max_governance_lines 100
  @max_template_lines 100

  @spec build(map(), map(), map()) :: String.t()
  def build(entry, target, opts) do
    assigns = base_assigns(entry, target, opts)
    render_prompt!("base.md.eex", assigns)
  end

  @spec build_structure_pass(map(), map(), map()) :: String.t()
  def build_structure_pass(entry, target, opts) do
    base_prompt = build(entry, target, opts)
    render_prompt!("pass_structure.md.eex", base_prompt: base_prompt)
  end

  @spec build_writing_pass(map(), map(), map(), map()) :: String.t()
  def build_writing_pass(entry, target, opts, structure_plan) do
    base_prompt = build(entry, target, opts)
    contract = Contract.contract(entry, target)

    structure_json =
      structure_plan
      |> stringify_map_keys()
      |> Jason.encode!(pretty: true)

    render_prompt!("pass_writer.md.eex",
      base_prompt: base_prompt,
      structure_json: structure_json,
      required_sections: contract.required_sections,
      min_words: contract.min_words,
      max_words: contract.max_words
    )
  end

  @spec system_prompt(:planner | :writer) :: String.t()
  def system_prompt(:planner), do: read_prompt!("system_planner.md")
  def system_prompt(:writer), do: read_prompt!("system_writer.md")

  defp base_assigns(entry, target, opts) do
    brand_context = read_file("JIDO_BRAND_CONTEXT.md") |> excerpt_lines(@max_brand_context_lines)
    docs_manifesto = read_file("specs/docs-manifesto.md") |> excerpt_lines(@max_manifesto_lines)
    content_governance = read_file("specs/content-governance.md") |> excerpt_lines(@max_governance_lines)
    template = template_for(entry, target) |> compact_template_guidance()
    existing = Map.get(opts, :existing)
    update_mode = Map.get(opts, :update_mode, :improve)
    source_snippets = source_snippets(entry)
    profile = Contract.profile(entry, target)
    prompt_overrides = Contract.prompt_overrides(entry)
    contract = Contract.contract(entry, target)

    [
      profile: profile,
      contract_rendered: render_contract(contract),
      entry_metadata_json: entry_metadata_json(entry),
      route: target.route,
      target_path: target.target_path,
      format: target.format,
      update_mode: update_mode,
      prompt_overrides_rendered: render_prompt_overrides(prompt_overrides),
      brand_context: brand_context,
      docs_manifesto: docs_manifesto,
      content_governance: content_governance,
      entry_brief: entry_brief(entry),
      template_guidance: template,
      existing_content: existing_content(existing),
      source_snippets_rendered: render_source_snippets(source_snippets)
    ]
  end

  defp template_for(entry, target) do
    path = template_path(entry, target)

    case path do
      nil -> "No template selected for this entry. Follow existing page structure and section conventions."
      template_path -> read_prompt!(template_path)
    end
  end

  defp compact_template_guidance(template) when is_binary(template) do
    template
    |> String.replace(~r/<!--.*?-->/s, "")
    |> excerpt_lines(@max_template_lines)
    |> String.trim()
    |> case do
      "" -> "(no template guidance)"
      text -> text
    end
  end

  defp template_path(entry, target) do
    cond do
      entry.section == "build" -> "templates/build-guide.md"
      entry.section == "training" -> "templates/training-module.md"
      entry.section == "features" -> "templates/feature-page.md"
      entry.section == "ecosystem" -> "templates/ecosystem-package.md"
      entry.section == "docs" and String.starts_with?(target.route, "/docs/reference") -> "templates/docs-reference.md"
      entry.section == "docs" -> "templates/docs-concept.md"
      true -> nil
    end
  end

  defp entry_brief(entry) do
    case Map.get(entry, :body) do
      body when is_binary(body) and body != "" ->
        normalized = normalize_brief_body(body)
        if normalized == "", do: "(no brief body provided)", else: normalized

      _other ->
        "(no brief body provided)"
    end
  end

  defp existing_content(nil), do: "(none)"

  defp existing_content(%{raw: raw}) when is_binary(raw) do
    """
    Existing page content:
    ```markdown
    #{raw}
    ```
    """
  end

  defp existing_content(_other), do: "(none)"

  defp source_snippets(entry) do
    files =
      entry
      |> Map.get(:source_files, [])
      |> List.wrap()
      |> expand_files(entry)
      |> Enum.uniq()
      |> Enum.take(@max_source_files)

    Enum.map(files, fn path ->
      %{
        path: path,
        snippet: file_snippet(path)
      }
    end)
  end

  defp expand_files(patterns, entry) do
    roots = source_roots(entry)
    cwd = File.cwd!()

    patterns
    |> Enum.flat_map(fn pattern -> expand_pattern(pattern, roots) end)
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&Path.relative_to(&1, cwd))
  end

  defp expand_pattern(pattern, roots) when is_binary(pattern) do
    cond do
      pattern == "" ->
        []

      wildcard_pattern?(pattern) ->
        Enum.flat_map(roots, fn root ->
          abs_pattern = Path.expand(pattern, root)
          Path.wildcard(abs_pattern)
        end)

      Path.type(pattern) == :absolute ->
        [pattern]

      true ->
        Enum.map(roots, &Path.expand(pattern, &1))
    end
  end

  defp expand_pattern(_pattern, _roots), do: []

  defp source_roots(entry) do
    cwd = File.cwd!()

    repo_ids =
      List.wrap(Map.get(entry, :repos, [])) ++
        List.wrap(Map.get(entry, :ecosystem_packages, []))

    repo_paths =
      repo_ids
      |> List.wrap()
      |> Enum.map(&to_string/1)
      |> Enum.flat_map(&repo_root_candidates(&1, cwd))

    ([cwd] ++ repo_paths)
    |> Enum.uniq()
    |> Enum.filter(&File.dir?/1)
  end

  defp repo_root_candidates(repo_id, cwd) when is_binary(repo_id) do
    normalized = String.trim(repo_id)
    dash_variant = String.replace(normalized, "_", "-")
    underscore_variant = String.replace(normalized, "-", "_")
    variants = [normalized, dash_variant, underscore_variant] |> Enum.uniq()

    parent_paths = Enum.map(variants, &Path.expand(Path.join("..", &1), cwd))
    deps_paths = Enum.map(variants, &Path.expand(Path.join("deps", &1), cwd))

    parent_paths ++ deps_paths
  end

  defp file_snippet(path) do
    lines =
      path
      |> File.read!()
      |> String.split("\n")

    {head, tail} = Enum.split(lines, @max_source_lines)
    snippet = Enum.join(head, "\n")

    if tail == [] do
      snippet
    else
      snippet <> "\n\n# [truncated source file for prompt focus]"
    end
  rescue
    _ -> "# Unable to read source snippet"
  end

  defp render_source_snippets([]), do: "(no source snippets provided)"

  defp render_source_snippets(snippets) do
    snippets
    |> Enum.map(fn %{path: path, snippet: snippet} ->
      """
      File: #{path}
      ```text
      #{snippet}
      ```
      """
    end)
    |> Enum.join("\n")
  end

  defp render_contract(contract) do
    """
    intent: #{contract.document_intent}
    word_range: #{contract.min_words}-#{contract.max_words}
    minimum_code_blocks: #{contract.minimum_code_blocks}
    minimum_module_fun_arity_refs: #{contract.minimum_fun_refs}
    diagram_policy: #{contract.diagram_policy}
    section_density: #{contract.section_density}
    max_paragraph_sentences: #{contract.max_paragraph_sentences}

    required_section_order:
    #{render_list(contract.required_sections)}

    must_include:
    #{render_list(contract.must_include)}

    must_avoid:
    #{render_list(contract.must_avoid)}

    required_internal_links (must resolve):
    #{render_list(contract.required_links)}

    extra_instructions:
    #{render_list(contract.extra_instructions)}
    """
  end

  defp render_prompt_overrides(overrides) do
    if map_size(overrides) == 0 do
      "(none)"
    else
      overrides
      |> stringify_map_keys()
      |> Jason.encode!(pretty: true)
    end
  end

  defp render_list([]), do: "- (none)"

  defp render_list(items) do
    items
    |> Enum.map(&"- #{&1}")
    |> Enum.join("\n")
  end

  defp normalize_brief_body(body) do
    body
    |> String.replace(~r/<li>/i, "- ")
    |> String.replace(~r/<\/li>/i, "\n")
    |> String.replace(~r/<\/?(h[1-6]|p|ul|ol)>/i, "\n")
    |> String.replace(~r/<br\s*\/?>/i, "\n")
    |> String.replace(~r/<[^>]+>/, "")
    |> String.replace("&nbsp;", " ")
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace(~r/\n{3,}/, "\n\n")
    |> String.trim()
  end

  defp wildcard_pattern?(pattern) do
    String.contains?(pattern, "*") or String.contains?(pattern, "?") or String.contains?(pattern, "[")
  end

  defp excerpt_lines(contents, max_lines) when is_binary(contents) do
    lines = String.split(contents, "\n")
    {head, tail} = Enum.split(lines, max_lines)
    excerpt = Enum.join(head, "\n")

    if tail == [] do
      excerpt
    else
      excerpt <> "\n\n[truncated for prompt focus]"
    end
  end

  defp stringify_map_keys(data) when is_map(data) do
    Map.new(data, fn {k, v} -> {to_string(k), stringify_map_keys(v)} end)
  end

  defp stringify_map_keys(data) when is_list(data), do: Enum.map(data, &stringify_map_keys/1)
  defp stringify_map_keys(data), do: data

  defp entry_metadata_json(entry) do
    entry_map =
      if is_struct(entry) do
        Map.from_struct(entry)
      else
        Map.new(entry)
      end

    entry_map
    |> Map.take([
      :id,
      :title,
      :section,
      :order,
      :status,
      :purpose,
      :audience,
      :content_type,
      :learning_outcomes,
      :repos,
      :source_modules,
      :source_files,
      :prerequisites,
      :related,
      :ecosystem_packages,
      :destination_route,
      :tags,
      :prompt_overrides
    ])
    |> stringify_map_keys()
    |> Jason.encode!(pretty: true)
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, contents} -> contents
      {:error, _} -> "(missing file: #{path})"
    end
  end

  defp render_prompt!(relative_path, assigns) do
    template = read_prompt!(relative_path)
    EEx.eval_string(template, assigns)
  end

  defp read_prompt!(relative_path) do
    path = prompt_path(relative_path)

    case File.read(path) do
      {:ok, contents} -> contents
      {:error, reason} -> raise "missing prompt file #{path}: #{inspect(reason)}"
    end
  end

  defp prompt_path(relative_path) do
    root =
      Application.get_env(:agent_jido, :content_gen_prompt_root, @default_prompt_root)
      |> to_string()

    if Path.type(root) == :absolute do
      Path.join(root, relative_path)
    else
      Path.join(Application.app_dir(:agent_jido), Path.join(root, relative_path))
    end
  end
end
