defmodule AgentJido.Blog.Taxonomy do
  @moduledoc """
  Canonical taxonomy helpers for blog tags and metadata.

  Aligns blog content with the site taxonomy model in `specs/taxonomy.md`.
  """

  @post_types [:post, :announcement, :release, :tutorial, :case_study]
  @audiences [:general, :beginner, :intermediate, :advanced]
  @journey_stages [:awareness, :orientation, :evaluation, :activation, :operationalization, :expansion, :advocacy]
  @content_intents [:explanation, :guide, :tutorial, :reference, :cookbook, :case_study, :decision_brief]
  @capability_themes [
    :runtime_foundations,
    :reliability_architecture,
    :coordination_orchestration,
    :operations_observability,
    :ai_intelligence,
    :execution_tooling,
    :integration_interop,
    :adoption_architecture,
    :learning_enablement,
    :community_adoption
  ]
  @evidence_surfaces [:package, :runnable_example, :training_module, :docs_reference, :runbook, :case_study]

  @default_tag_aliases %{
    "agents" => "agent",
    "llms" => "llm",
    "req" => "req_llm",
    "req-llm" => "req_llm",
    "reqllm" => "req_llm",
    "signal" => "signals"
  }

  @type metadata :: %{
          post_type: atom(),
          audience: atom(),
          tags: [String.t()],
          journey_stage: atom(),
          content_intent: atom(),
          capability_theme: atom(),
          evidence_surface: atom()
        }

  @spec post_types() :: [atom()]
  def post_types, do: @post_types

  @spec audiences() :: [atom()]
  def audiences, do: @audiences

  @spec journey_stages() :: [atom()]
  def journey_stages, do: @journey_stages

  @spec content_intents() :: [atom()]
  def content_intents, do: @content_intents

  @spec capability_themes() :: [atom()]
  def capability_themes, do: @capability_themes

  @spec evidence_surfaces() :: [atom()]
  def evidence_surfaces, do: @evidence_surfaces

  @spec default_tag_aliases() :: %{String.t() => String.t()}
  def default_tag_aliases, do: @default_tag_aliases

  @spec default_tag_alias_rows() :: [%{legacy_tag: String.t(), canonical_tag: String.t()}]
  def default_tag_alias_rows do
    @default_tag_aliases
    |> Enum.map(fn {legacy_tag, canonical_tag} ->
      %{legacy_tag: legacy_tag, canonical_tag: canonical_tag}
    end)
    |> Enum.sort_by(& &1.legacy_tag)
  end

  @spec normalize_tag_token(term()) :: String.t() | nil
  def normalize_tag_token(nil), do: nil
  def normalize_tag_token(true), do: nil
  def normalize_tag_token(false), do: nil

  def normalize_tag_token(tag) when is_binary(tag) do
    tag
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/\s+/, "_")
    |> case do
      "" -> nil
      value -> value
    end
  end

  def normalize_tag_token(tag) when is_atom(tag), do: tag |> Atom.to_string() |> normalize_tag_token()
  def normalize_tag_token(_tag), do: nil

  @spec canonical_tag(term()) :: String.t() | nil
  def canonical_tag(tag) do
    case normalize_tag_token(tag) do
      nil -> nil
      normalized -> Map.get(@default_tag_aliases, normalized, normalized)
    end
  end

  @spec normalize_tags(list()) :: [String.t()]
  def normalize_tags(tags) when is_list(tags) do
    tags
    |> Enum.reduce([], fn tag, acc ->
      case canonical_tag(tag) do
        nil ->
          acc

        canonical ->
          append_unique(acc, canonical)
      end
    end)
  end

  def normalize_tags(_tags), do: []

  @spec tag_aliases_for(list()) :: [%{legacy_tag: String.t(), canonical_tag: String.t()}]
  def tag_aliases_for(tags) when is_list(tags) do
    tags
    |> Enum.reduce([], fn tag, acc ->
      legacy = normalize_tag_token(tag)
      canonical = canonical_tag(tag)

      if legacy in [nil, ""] or canonical in [nil, ""] or legacy == canonical do
        acc
      else
        [%{legacy_tag: legacy, canonical_tag: canonical} | acc]
      end
    end)
    |> Enum.uniq_by(& &1.legacy_tag)
    |> Enum.sort_by(& &1.legacy_tag)
  end

  def tag_aliases_for(_tags), do: []

  @spec metadata(term(), term(), list(), keyword() | map()) :: metadata()
  def metadata(post_type, audience, tags, attrs \\ %{}) do
    attrs = normalize_attrs(attrs)
    canonical_tags = normalize_tags(tags)
    normalized_post_type = normalize_enum(post_type, @post_types, :post)
    normalized_audience = normalize_enum(audience, @audiences, :general)

    content_intent =
      attrs
      |> value_for(:content_intent)
      |> normalize_enum(@content_intents, nil)
      |> Kernel.||(infer_content_intent(normalized_post_type))

    capability_theme =
      attrs
      |> value_for(:capability_theme)
      |> normalize_enum(@capability_themes, nil)
      |> Kernel.||(infer_capability_theme(canonical_tags))

    journey_stage =
      attrs
      |> value_for(:journey_stage)
      |> normalize_enum(@journey_stages, nil)
      |> Kernel.||(infer_journey_stage(content_intent, normalized_post_type))

    evidence_surface =
      attrs
      |> value_for(:evidence_surface)
      |> normalize_enum(@evidence_surfaces, nil)
      |> Kernel.||(infer_evidence_surface(normalized_post_type, canonical_tags))

    %{
      post_type: normalized_post_type,
      audience: normalized_audience,
      tags: canonical_tags,
      journey_stage: journey_stage,
      content_intent: content_intent,
      capability_theme: capability_theme,
      evidence_surface: evidence_surface
    }
  end

  defp normalize_attrs(attrs) when is_map(attrs), do: attrs
  defp normalize_attrs(attrs) when is_list(attrs), do: Map.new(attrs)
  defp normalize_attrs(_attrs), do: %{}

  defp value_for(attrs, key) do
    Map.get(attrs, key) || Map.get(attrs, Atom.to_string(key))
  end

  defp normalize_enum(value, allowed, default) do
    normalized =
      case value do
        atom when is_atom(atom) ->
          if Enum.member?(allowed, atom), do: atom, else: nil

        binary when is_binary(binary) ->
          string_value = binary |> String.trim() |> String.downcase()
          Enum.find(allowed, &(Atom.to_string(&1) == string_value))

        _other ->
          nil
      end

    normalized || default
  end

  defp infer_content_intent(:tutorial), do: :tutorial
  defp infer_content_intent(:case_study), do: :case_study
  defp infer_content_intent(:announcement), do: :decision_brief
  defp infer_content_intent(:release), do: :reference
  defp infer_content_intent(_), do: :explanation

  defp infer_capability_theme(tags) do
    Enum.find_value(capability_theme_rules(), :runtime_foundations, fn {theme, matches} ->
      if has_any?(tags, matches), do: theme
    end)
  end

  defp append_unique(items, item) do
    if Enum.member?(items, item), do: items, else: items ++ [item]
  end

  defp capability_theme_rules do
    [
      {:coordination_orchestration, ["signals", "workflow", "workflows", "directives"]},
      {:operations_observability, ["telemetry", "observability", "tracing", "ops"]},
      {:ai_intelligence, ["llm", "req_llm", "langchain", "ai", "memory"]},
      {:integration_interop, ["integration", "interop", "adapters", "phoenix", "liveview"]},
      {:execution_tooling, ["shell", "vfs", "sandbox", "workspace"]},
      {:adoption_architecture, ["adoption", "architecture", "decision"]},
      {:learning_enablement, ["training", "learning"]},
      {:community_adoption, ["community", "case-study"]},
      {:reliability_architecture, ["reliability", "supervision", "otp"]}
    ]
  end

  defp infer_journey_stage(:tutorial, _post_type), do: :activation
  defp infer_journey_stage(:guide, _post_type), do: :activation
  defp infer_journey_stage(:cookbook, _post_type), do: :activation
  defp infer_journey_stage(:reference, _post_type), do: :operationalization
  defp infer_journey_stage(:decision_brief, _post_type), do: :evaluation
  defp infer_journey_stage(:case_study, _post_type), do: :advocacy
  defp infer_journey_stage(:explanation, :announcement), do: :evaluation
  defp infer_journey_stage(:explanation, :release), do: :evaluation
  defp infer_journey_stage(_content_intent, _post_type), do: :orientation

  defp infer_evidence_surface(:case_study, _tags), do: :case_study
  defp infer_evidence_surface(:tutorial, _tags), do: :runnable_example

  defp infer_evidence_surface(_post_type, tags) do
    cond do
      has_any?(tags, ["runbook", "ops", "operations"]) -> :runbook
      has_any?(tags, ["training", "learning"]) -> :training_module
      has_any?(tags, ["req_llm", "jido", "agent", "signals", "llm", "langchain"]) -> :package
      true -> :docs_reference
    end
  end

  defp has_any?(tags, candidates) do
    normalized = MapSet.new(tags || [])

    Enum.any?(candidates, fn candidate ->
      MapSet.member?(normalized, candidate)
    end)
  end
end
