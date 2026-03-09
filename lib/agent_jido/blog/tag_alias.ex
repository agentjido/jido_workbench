defmodule AgentJido.Blog.TagAlias do
  @moduledoc """
  Canonical redirect mapping for legacy blog tags.
  """

  alias AgentJido.Blog.Taxonomy

  @spec canonical_tag_for(String.t()) :: String.t() | nil
  def canonical_tag_for(legacy_tag) when is_binary(legacy_tag) do
    normalized = Taxonomy.normalize_tag_token(legacy_tag)

    if normalized in [nil, ""] do
      nil
    else
      canonical = Map.get(Taxonomy.default_tag_aliases(), normalized)

      case Taxonomy.canonical_tag(canonical) do
        value when is_binary(value) and value != "" and value != normalized -> value
        _ -> nil
      end
    end
  end

  def canonical_tag_for(_legacy_tag), do: nil
end
