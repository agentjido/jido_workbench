defmodule AgentJido.ContentGen.Contract do
  @moduledoc """
  Shared authoring contract logic for content generation prompts and auditing.
  """

  @docs_hub_tags [:hub_getting_started, :hub_concepts, :hub_guides, :hub_reference, :hub_operations]

  @type profile ::
          :docs_concept
          | :docs_reference
          | :docs_guide
          | :docs_operations
          | :docs_getting_started
          | :livebook_general
          | :general

  @type contract :: %{
          profile: profile(),
          document_intent: String.t(),
          min_words: pos_integer(),
          max_words: pos_integer(),
          minimum_code_blocks: non_neg_integer(),
          minimum_fun_refs: non_neg_integer(),
          diagram_policy: String.t(),
          section_density: String.t(),
          max_paragraph_sentences: pos_integer(),
          required_sections: [String.t()],
          must_include: [String.t()],
          must_avoid: [String.t()],
          required_links: [String.t()],
          extra_instructions: [String.t()]
        }

  @spec profile(map(), map()) :: profile()
  def profile(entry, target) do
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

  @spec prompt_overrides(map()) :: map()
  def prompt_overrides(entry) do
    entry
    |> Map.get(:prompt_overrides, %{})
    |> normalize_prompt_overrides()
  end

  @spec contract(map(), map()) :: contract()
  def contract(entry, target) do
    profile = profile(entry, target)
    overrides = prompt_overrides(entry)

    authoring_contract(entry, target, profile, overrides)
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
      minimum_code_blocks:
        override_non_negative_integer(
          prompt_overrides,
          :minimum_code_blocks,
          base.minimum_code_blocks
        ),
      minimum_fun_refs: override_non_negative_integer(prompt_overrides, :minimum_fun_refs, base.minimum_fun_refs),
      diagram_policy:
        override_string(prompt_overrides, :diagram_policy) ||
          base.diagram_policy,
      section_density:
        override_string(prompt_overrides, :section_density) ||
          default_section_density(profile),
      max_paragraph_sentences:
        override_integer(
          prompt_overrides,
          :max_paragraph_sentences,
          default_max_paragraph_sentences(profile)
        ),
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
      min_words: 650,
      max_words: 1_300,
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
      min_words: 700,
      max_words: 1_500,
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
      document_intent: "Write an executable run-along tutorial where each step is runnable in Livebook and includes clear checkpoints.",
      min_words: 650,
      max_words: 1_400,
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
        "At least one validation step with expected output.",
        "Progressive runnable code cells that developers can execute in order."
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
      minimum_fun_refs: 0,
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

  defp default_section_density(:docs_concept), do: "light_technical"
  defp default_section_density(:docs_guide), do: "task_focused"
  defp default_section_density(:docs_getting_started), do: "highly_scannable"
  defp default_section_density(:livebook_general), do: "step_oriented"
  defp default_section_density(_profile), do: "balanced"

  defp default_max_paragraph_sentences(:docs_concept), do: 4
  defp default_max_paragraph_sentences(:docs_guide), do: 4
  defp default_max_paragraph_sentences(:docs_getting_started), do: 3
  defp default_max_paragraph_sentences(:livebook_general), do: 3
  defp default_max_paragraph_sentences(_profile), do: 4

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

  defp override_non_negative_integer(overrides, key, default) do
    case override_get(overrides, key, default) do
      value when is_integer(value) and value >= 0 ->
        value

      value when is_binary(value) ->
        case Integer.parse(String.trim(value)) do
          {int, ""} when int >= 0 -> int
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
end
