defmodule AgentJido.Blog.SlugAlias do
  @moduledoc """
  Canonical redirect mapping for legacy blog slugs derived from static content.
  """
  alias AgentJido.Blog.Legacy

  @spec canonical_slug_for(String.t()) :: String.t() | nil
  def canonical_slug_for(legacy_slug) when is_binary(legacy_slug) do
    Legacy.canonical_slug_for(legacy_slug)
  end

  def canonical_slug_for(_legacy_slug), do: nil
end
