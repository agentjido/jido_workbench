defmodule AgentJido.Pages.ContentExpander do
  @moduledoc false

  alias AgentJido.Ecosystem.Atlas
  alias AgentJido.ReleaseCatalog

  @spec expand(String.t()) :: String.t()
  def expand(contents) when is_binary(contents) do
    contents
    |> ReleaseCatalog.expand_placeholders()
    |> String.replace(Atlas.placeholder(), Atlas.render_markdown())
  end
end
