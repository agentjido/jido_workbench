defmodule AgentJido.Demos.PluginBasicsAgent do
  @moduledoc """
  Demo agent that composes behavior via a custom plugin.
  """

  alias AgentJido.Demos.PluginBasics.NotesPlugin

  use Jido.Agent,
    name: "plugin_basics_agent",
    description: "Demonstrates plugin mount state and signal routing",
    schema: [
      status: [type: :atom, default: :ready]
    ],
    plugins: [{NotesPlugin, %{label: "demo"}}]

  @doc false
  @spec plugin_specs() :: nonempty_list(Jido.Plugin.Spec.t())
  def plugin_specs, do: super()
end
