defmodule AgentJido.ContentGen.PromptBuilder do
  @moduledoc """
  Builds generation prompts from content-plan metadata, templates, and source context.
  """

  @max_source_files 4
  @max_source_lines 80
  @max_brand_context_lines 140
  @max_manifesto_lines 240
  @max_governance_lines 140
  @max_template_lines 140

  @docs_hub_tags [:hub_getting_started, :hub_concepts, :hub_guides, :hub_reference, :hub_operations]

  @spec build(struct(), map(), map()) :: String.t()
  def build(entry, target, opts) do
    brand_context = read_file("JIDO_BRAND_CONTEXT.md") |> excerpt_lines(@max_brand_context_lines)
    docs_manifesto = read_file("specs/docs-manifesto.md") |> excerpt_lines(@max_manifesto_lines)
    content_governance = read_file("specs/content-governance.md") |> excerpt_lines(@max_governance_lines)
    template = template_for(entry, target) |> compact_template_guidance()
    existing = Map.get(opts, :existing)
    update_mode = Map.get(opts, :update_mode, :improve)
    source_snippets = source_snippets(entry)
    profile = page_profile(entry, target)
    prompt_overrides = normalize_prompt_overrides(Map.get(entry, :prompt_overrides, %{}))
    contract = authoring_contract(entry, target, profile, prompt_overrides)

    """
    You are a principal documentation author for agentjido.xyz. Write an authoritative technical guide from the content-plan brief.

    PRIORITY ORDER:
    1) factual accuracy against source modules/files
    2) practical developer utility
    3) clear, direct prose
    4) completeness without filler

    QUALITY BAR (docs-manifesto aligned):
    - Start with "what this solves" and "when to use it" before deep theory.
    - Show the after-state and quick setup early; avoid slow preambles.
    - Use progressive examples: minimal -> realistic -> production caveats.
    - Keep claims bounded, concrete, and evidence-backed.
    - Write to one developer ("you"), with staff-engineer clarity.
    - No placeholders (TODO/TBD/coming soon/lorem ipsum).
    - End with clear references and next practical links.

    STRICT CONTENT RULES:
    - Do not return thin scaffolding; each required section must contain specific substance.
    - Do not repeat the page title line in multiple headings.
    - Use real module/function names and arities when cited.
    - Never mention internal workspace-only tooling in public docs.
    - Mermaid diagrams are selective: only include when required by the contract/policy below.

    OUTPUT CONTRACT:
    Return ONLY one JSON object with this shape:
    {
      "frontmatter": { ... },
      "body_markdown": "...",
      "citations": ["..."],
      "audit_notes": ["..."]
    }

    JSON constraints:
    - body_markdown must be plain markdown (no surrounding ``` fences)
    - frontmatter must include at minimum: title, description
    - preserve route intent for #{target.route}
    - if update_mode is improve, improve the existing page in-place (do not reset quality/structure)
    - citations must list source modules/files actually used while writing

    === Page profile ===
    #{profile}

    === Authoring contract ===
    #{render_contract(contract)}

    === Entry metadata ===
    #{entry_metadata_json(entry)}

    === Target ===
    route: #{target.route}
    target_path: #{target.target_path}
    format: #{target.format}
    update_mode: #{update_mode}

    === Entry prompt overrides ===
    #{render_prompt_overrides(prompt_overrides)}

    === Brand context (excerpt) ===
    #{brand_context}

    === Docs manifesto (excerpt) ===
    #{docs_manifesto}

    === Content governance (excerpt) ===
    #{content_governance}

    === Entry brief ===
    #{entry_brief(entry)}

    === Template guidance ===
    #{template}

    === Existing file content ===
    #{existing_content(existing)}

    === Source snippets ===
    #{render_source_snippets(source_snippets)}
    """
  end

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

  defp template_for(entry, target) do
    path = template_path(entry, target)

    case path do
      nil -> "No template selected for this entry. Follow existing page structure and section conventions."
      template_path -> read_file(template_path)
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
      entry.section == "build" -> "specs/templates/build-guide.md"
      entry.section == "training" -> "specs/templates/training-module.md"
      entry.section == "features" -> "specs/templates/feature-page.md"
      entry.section == "ecosystem" -> "specs/templates/ecosystem-package.md"
      entry.section == "docs" and String.starts_with?(target.route, "/docs/reference") -> "specs/templates/docs-reference.md"
      entry.section == "docs" -> "specs/templates/docs-concept.md"
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
    path
    |> File.stream!([], :line)
    |> Enum.take(@max_source_lines)
    |> Enum.join()
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

  defp page_profile(entry, target) do
    hub = docs_hub(entry)

    cond do
      entry.section == "docs" and hub == :hub_reference -> :docs_reference
      entry.section == "docs" and hub == :hub_guides -> :docs_guide
      entry.section == "docs" and hub == :hub_concepts -> :docs_concept
      entry.section == "docs" and hub == :hub_operations -> :docs_operations
      entry.section == "docs" and hub == :hub_getting_started -> :docs_getting_started
      target.format == :livemd -> :livebook_general
      true -> :general
    end
  end

  defp docs_hub(entry) do
    tags = entry |> Map.get(:tags, []) |> List.wrap()
    Enum.find(@docs_hub_tags, &(&1 in tags))
  end

  defp authoring_contract(entry, target, profile, prompt_overrides) do
    base = base_contract(entry, target, profile)

    required_sections_override = override_list(prompt_overrides, :required_sections)
    must_include_override = override_list(prompt_overrides, :must_include)
    must_avoid_override = override_list(prompt_overrides, :must_avoid)
    required_links_override = override_list(prompt_overrides, :required_links)
    extra_instructions = override_list(prompt_overrides, :extra_instructions)

    required_sections =
      merge_list(base.required_sections, required_sections_override,
        replace?: truthy?(override_get(prompt_overrides, :replace_required_sections, false))
      )

    %{
      profile: profile,
      document_intent:
        override_string(prompt_overrides, :document_intent) ||
          base.document_intent,
      min_words: override_integer(prompt_overrides, :min_words, base.min_words),
      max_words: override_integer(prompt_overrides, :max_words, base.max_words),
      minimum_code_blocks: override_integer(prompt_overrides, :minimum_code_blocks, base.minimum_code_blocks),
      minimum_fun_refs: override_integer(prompt_overrides, :minimum_fun_refs, base.minimum_fun_refs),
      diagram_policy:
        override_string(prompt_overrides, :diagram_policy) ||
          base.diagram_policy,
      required_sections: required_sections,
      must_include: Enum.uniq(base.must_include ++ must_include_override),
      must_avoid: Enum.uniq(base.must_avoid ++ must_avoid_override),
      required_links: Enum.uniq(base.required_links ++ required_links_override),
      extra_instructions: extra_instructions
    }
    |> normalize_word_range()
  end

  defp base_contract(entry, target, :docs_concept) do
    title = Map.get(entry, :title, "Concept")

    %{
      document_intent:
        "Write an authoritative concept guide that defines what #{title} means in the Jido runtime model and how it is used in real systems.",
      min_words: 900,
      max_words: 1_800,
      minimum_code_blocks: if(target.format == :livemd, do: 3, else: 2),
      minimum_fun_refs: 3,
      diagram_policy: "optional",
      required_sections: [
        "What This Solves",
        "When to Use It",
        "Definition and Mental Model",
        "Quick Start",
        "How It Works",
        "Progressive Examples",
        "Failure Modes and Operational Boundaries",
        "Reference and Next Steps"
      ],
      must_include: [
        "A precise definition in Jido terms, including what this concept is not.",
        "At least one runnable minimal example and one realistic example.",
        "Concrete callouts of modules/functions that enforce the behavior."
      ],
      must_avoid: [
        "Generic framework-agnostic AI advice.",
        "Marketing language and unbounded performance claims."
      ],
      required_links: ["/docs/reference", "/docs/operations", "/build"]
    }
  end

  defp base_contract(_entry, _target, :docs_reference) do
    %{
      document_intent: "Write a reference-grade page that maps exact API contracts to practical usage and limits.",
      min_words: 750,
      max_words: 1_500,
      minimum_code_blocks: 2,
      minimum_fun_refs: 5,
      diagram_policy: "forbidden unless architecture flow is required",
      required_sections: [
        "Overview and Scope",
        "API Surface Map",
        "Configuration and Contracts",
        "Examples",
        "Compatibility and Maturity",
        "Related Reference and Next Steps"
      ],
      must_include: [
        "Function/module references with arities when behavior is described.",
        "Package maturity caveats when APIs are beta or experimental."
      ],
      must_avoid: [
        "Speculative API descriptions not present in source."
      ],
      required_links: ["/docs/reference", "/docs/guides", "/docs/operations"]
    }
  end

  defp base_contract(_entry, target, :docs_guide) do
    %{
      document_intent: "Write a task-driven implementation guide that gets a developer from setup to a reliable working result.",
      min_words: 850,
      max_words: 1_900,
      minimum_code_blocks: if(target.format == :livemd, do: 4, else: 3),
      minimum_fun_refs: 3,
      diagram_policy: "optional",
      required_sections: [
        "What This Solves",
        "When to Use This Guide",
        "Prerequisites",
        "Quick Setup",
        "Step-by-Step Implementation",
        "Validation and Troubleshooting",
        "Production Caveats",
        "Reference and Next Steps"
      ],
      must_include: [
        "A minimal runnable path before deep explanation.",
        "Operational caveats or failure recovery notes."
      ],
      must_avoid: [
        "Skipping verification steps.",
        "Unexplained jumps between setup and production guidance."
      ],
      required_links: ["/docs/reference", "/docs/operations", "/build"]
    }
  end

  defp base_contract(_entry, _target, :docs_operations) do
    %{
      document_intent: "Write an operationally actionable page for reliability, governance, and incident handling.",
      min_words: 700,
      max_words: 1_600,
      minimum_code_blocks: 1,
      minimum_fun_refs: 2,
      diagram_policy: "optional",
      required_sections: [
        "Operational Goal",
        "When This Applies",
        "Baseline Controls",
        "Failure Scenarios",
        "Verification Checklist",
        "Escalation and Next Steps"
      ],
      must_include: [
        "Explicit checks that an on-call or platform engineer can execute."
      ],
      must_avoid: [
        "Ambiguous runbook steps."
      ],
      required_links: ["/docs/reference", "/docs/guides"]
    }
  end

  defp base_contract(_entry, target, :docs_getting_started) do
    %{
      document_intent: "Write a first-success path that gets a developer to a working result quickly, then orients them to deeper docs.",
      min_words: 700,
      max_words: 1_500,
      minimum_code_blocks: if(target.format == :livemd, do: 3, else: 2),
      minimum_fun_refs: 2,
      diagram_policy: "forbidden",
      required_sections: [
        "What You Will Build",
        "When to Use This Path",
        "Quick Setup",
        "First Working Example",
        "How to Verify It Works",
        "Where to Go Next"
      ],
      must_include: [
        "One path that can be completed in a single sitting."
      ],
      must_avoid: [
        "Heavy theory before first success."
      ],
      required_links: ["/docs/concepts", "/docs/guides", "/build"]
    }
  end

  defp base_contract(_entry, target, :livebook_general) do
    %{
      document_intent: "Write an executable tutorial with clear setup, runnable steps, and checkpoints.",
      min_words: 700,
      max_words: 1_700,
      minimum_code_blocks: if(target.format == :livemd, do: 4, else: 2),
      minimum_fun_refs: 2,
      diagram_policy: "optional",
      required_sections: [
        "What This Solves",
        "Prerequisites",
        "Setup",
        "Runnable Steps",
        "Validation",
        "Next Steps"
      ],
      must_include: [
        "At least one validation step with expected output."
      ],
      must_avoid: [
        "Unverifiable pseudo-code."
      ],
      required_links: ["/docs", "/build"]
    }
  end

  defp base_contract(_entry, _target, :general) do
    %{
      document_intent: "Write a specific, useful technical page that follows the entry brief and source evidence.",
      min_words: 600,
      max_words: 1_400,
      minimum_code_blocks: 1,
      minimum_fun_refs: 1,
      diagram_policy: "optional",
      required_sections: [
        "What This Solves",
        "How to Use It",
        "Examples",
        "References and Next Steps"
      ],
      must_include: [],
      must_avoid: ["placeholder content and unsupported claims"],
      required_links: ["/docs"]
    }
  end

  defp render_contract(contract) do
    """
    intent: #{contract.document_intent}
    word_range: #{contract.min_words}-#{contract.max_words}
    minimum_code_blocks: #{contract.minimum_code_blocks}
    minimum_module_fun_arity_refs: #{contract.minimum_fun_refs}
    diagram_policy: #{contract.diagram_policy}

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

  defp normalize_prompt_overrides(overrides) when is_map(overrides), do: overrides

  defp normalize_prompt_overrides(overrides) when is_list(overrides) do
    if Keyword.keyword?(overrides) do
      Map.new(overrides)
    else
      %{"list" => overrides}
    end
  end

  defp normalize_prompt_overrides(_other), do: %{}

  defp merge_list(base, override, opts) do
    replace? = Keyword.get(opts, :replace?, false)

    cond do
      replace? and override != [] -> Enum.uniq(override)
      true -> Enum.uniq(base ++ override)
    end
  end

  defp override_get(overrides, key, default \\ nil) do
    Map.get(overrides, key, Map.get(overrides, Atom.to_string(key), default))
  end

  defp override_string(overrides, key) do
    case override_get(overrides, key) do
      value when is_binary(value) ->
        trimmed = String.trim(value)
        if trimmed == "", do: nil, else: trimmed

      value when is_atom(value) ->
        value |> Atom.to_string() |> String.trim()

      _ ->
        nil
    end
  end

  defp override_list(overrides, key) do
    overrides
    |> override_get(key, [])
    |> List.wrap()
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp override_integer(overrides, key, default) do
    case override_get(overrides, key, default) do
      value when is_integer(value) and value > 0 ->
        value

      value when is_binary(value) ->
        case Integer.parse(String.trim(value)) do
          {int, ""} when int > 0 -> int
          _ -> default
        end

      _ ->
        default
    end
  end

  defp truthy?(value) when value in [true, "true", "TRUE", "True", 1], do: true
  defp truthy?(_value), do: false

  defp normalize_word_range(contract) do
    min_words = contract.min_words
    max_words = max(contract.max_words, min_words + 100)

    %{contract | min_words: min_words, max_words: max_words}
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

  defp read_file(path) do
    case File.read(path) do
      {:ok, contents} -> contents
      {:error, _} -> "(missing file: #{path})"
    end
  end
end
