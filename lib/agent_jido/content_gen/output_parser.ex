defmodule AgentJido.ContentGen.OutputParser do
  @moduledoc """
  Parses backend output into a normalized generation envelope.
  """

  @allowed_frontmatter_keys %{
    "title" => :title,
    "description" => :description,
    "category" => :category,
    "legacy_paths" => :legacy_paths,
    "tags" => :tags,
    "order" => :order,
    "menu_label" => :menu_label,
    "in_menu" => :in_menu,
    "draft" => :draft,
    "doc_type" => :doc_type,
    "audience" => :audience,
    "track" => :track,
    "difficulty" => :difficulty,
    "duration_minutes" => :duration_minutes,
    "prerequisites" => :prerequisites,
    "learning_outcomes" => :learning_outcomes
  }

  @frontmatter_enum_values %{
    category: %{
      "docs" => :docs,
      "training" => :training,
      "features" => :features,
      "build" => :build,
      "community" => :community,
      "ecosystem" => :ecosystem,
      "examples" => :examples
    },
    doc_type: %{
      "guide" => :guide,
      "reference" => :reference,
      "tutorial" => :tutorial,
      "explanation" => :explanation,
      "cookbook" => :cookbook
    },
    audience: %{
      "beginner" => :beginner,
      "intermediate" => :intermediate,
      "advanced" => :advanced
    },
    track: %{
      "foundations" => :foundations,
      "coordination" => :coordination,
      "integration" => :integration,
      "operations" => :operations
    },
    difficulty: %{
      "beginner" => :beginner,
      "intermediate" => :intermediate,
      "advanced" => :advanced
    }
  }

  @spec parse(String.t()) ::
          {:ok, %{frontmatter: map(), body_markdown: String.t(), citations: [String.t()], audit_notes: [String.t()]}}
          | {:error, String.t()}
  def parse(text) when is_binary(text) do
    with {:ok, decoded} <- decode_json(text),
         {:ok, envelope} <- normalize_envelope(decoded) do
      {:ok, envelope}
    end
  end

  defp decode_json(text) do
    candidates = [
      String.trim(text),
      extract_fenced_json(text),
      extract_first_object(text)
    ]

    candidates
    |> Enum.reject(&is_nil_or_empty/1)
    |> Enum.reduce_while({:error, "unable to decode backend output as JSON envelope"}, fn candidate, _acc ->
      case Jason.decode(candidate) do
        {:ok, decoded} -> {:halt, {:ok, decoded}}
        {:error, _} -> {:cont, {:error, "unable to decode backend output as JSON envelope"}}
      end
    end)
  end

  defp normalize_envelope(%{"frontmatter" => frontmatter, "body_markdown" => body} = decoded)
       when is_map(frontmatter) and is_binary(body) do
    citations = normalize_string_list(decoded["citations"] || [])
    audit_notes = normalize_string_list(decoded["audit_notes"] || [])

    {:ok,
     %{
       frontmatter: normalize_frontmatter(frontmatter),
       body_markdown: String.trim_trailing(body) <> "\n",
       citations: citations,
       audit_notes: audit_notes
     }}
  end

  defp normalize_envelope(%{frontmatter: frontmatter, body_markdown: body} = decoded)
       when is_map(frontmatter) and is_binary(body) do
    citations = normalize_string_list(decoded[:citations] || [])
    audit_notes = normalize_string_list(decoded[:audit_notes] || [])

    {:ok,
     %{
       frontmatter: normalize_frontmatter(frontmatter),
       body_markdown: String.trim_trailing(body) <> "\n",
       citations: citations,
       audit_notes: audit_notes
     }}
  end

  defp normalize_envelope(_other), do: {:error, "JSON envelope missing required keys frontmatter/body_markdown"}

  defp normalize_frontmatter(frontmatter) do
    frontmatter
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      atom_key = normalize_frontmatter_key(key)

      if atom_key do
        case normalize_frontmatter_value(atom_key, value) do
          nil -> acc
          normalized -> Map.put(acc, atom_key, normalized)
        end
      else
        acc
      end
    end)
  end

  defp normalize_frontmatter_key(key) when is_atom(key), do: Map.get(@allowed_frontmatter_keys, Atom.to_string(key))
  defp normalize_frontmatter_key(key) when is_binary(key), do: Map.get(@allowed_frontmatter_keys, key)
  defp normalize_frontmatter_key(_key), do: nil

  defp normalize_frontmatter_value(key, value) when key in [:category, :doc_type, :audience, :track, :difficulty] do
    safe_enum_atom(key, value)
  end

  defp normalize_frontmatter_value(key, value) when key in [:order, :duration_minutes], do: normalize_integer(value)
  defp normalize_frontmatter_value(key, value) when key in [:draft, :in_menu], do: normalize_boolean(value)
  defp normalize_frontmatter_value(_key, value), do: value

  defp normalize_string_list(items) when is_list(items), do: Enum.map(items, &to_string/1)
  defp normalize_string_list(_other), do: []

  defp safe_enum_atom(key, value) when is_atom(value) do
    values = Map.get(@frontmatter_enum_values, key, %{})

    if Enum.any?(values, fn {_k, allowed_value} -> allowed_value == value end), do: value, else: nil
  end

  defp safe_enum_atom(key, value) when is_binary(value) do
    normalized =
      value
      |> String.trim()
      |> String.downcase()
      |> String.replace("-", "_")

    @frontmatter_enum_values
    |> Map.get(key, %{})
    |> Map.get(normalized)
  end

  defp safe_enum_atom(_key, _value), do: nil

  defp normalize_integer(value) when is_integer(value), do: value

  defp normalize_integer(value) when is_binary(value) do
    case Integer.parse(String.trim(value)) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp normalize_integer(_value), do: nil

  defp normalize_boolean(value) when is_boolean(value), do: value

  defp normalize_boolean(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "true" -> true
      "false" -> false
      _ -> nil
    end
  end

  defp normalize_boolean(_value), do: nil

  defp extract_fenced_json(text) do
    case Regex.run(~r/```json\s*(\{.*?\})\s*```/s, text) do
      [_, body] -> body
      _ -> nil
    end
  end

  defp extract_first_object(text) do
    case Regex.run(~r/(\{.*\})/s, text) do
      [_, body] -> body
      _ -> nil
    end
  end

  defp is_nil_or_empty(nil), do: true
  defp is_nil_or_empty(""), do: true
  defp is_nil_or_empty(_), do: false
end
