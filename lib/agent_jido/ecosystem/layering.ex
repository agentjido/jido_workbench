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
    "jido_shell" => :foundation,
    "jido_vfs" => :foundation,
    "jido" => :core,
    "jido_ai" => :ai,
    "jido_browser" => :ai,
    "jido_memory" => :ai,
    "jido_behaviortree" => :ai,
    "jido_runic" => :ai,
    "ash_jido" => :app,
    "jido_studio" => :app,
    "jido_messaging" => :app,
    "jido_otel" => :app
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
