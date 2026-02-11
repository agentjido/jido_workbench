defmodule AgentJido.Ecosystem.Layering do
  @moduledoc """
  Canonical layer mapping for ecosystem visualizations.
  """

  @type layer :: :foundation | :core | :ai | :app

  @id_overrides %{
    "llm_db" => :foundation,
    "req_llm" => :foundation,
    "jido_action" => :foundation,
    "jido_signal" => :foundation,
    "jido" => :core
  }

  @category_defaults %{
    core: :core,
    ai: :ai,
    integrations: :app,
    tools: :app,
    runtime: :app
  }

  @spec layer_for(map()) :: layer()
  def layer_for(package) when is_map(package) do
    id = Map.get(package, :id)
    category = Map.get(package, :category)

    Map.get(@id_overrides, id) || Map.get(@category_defaults, category, :app)
  end
end
