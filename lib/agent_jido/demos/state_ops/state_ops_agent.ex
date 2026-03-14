defmodule AgentJido.Demos.StateOpsAgent do
  @moduledoc """
  Demo agent for `StateOp` mutation patterns.
  """

  alias AgentJido.Demos.StateOps.{
    MergeMetadataAction,
    ReplaceAllAction,
    ClearTempDataAction,
    SetNestedValueAction,
    DeleteNestedValueAction
  }

  use Jido.Agent,
    name: "state_ops_agent",
    description: "Demonstrates SetState/ReplaceState/DeleteKeys/SetPath/DeletePath",
    schema: [
      counter: [type: :integer, default: 0],
      name: [type: :string, default: "demo"],
      metadata: [type: :map, default: %{}],
      temp: [type: :any, default: "scratch"],
      cache: [type: :any, default: %{hot: true}],
      config: [type: :map, default: %{timeout: 1000, secret: "token"}],
      step: [type: :atom, default: :idle]
    ],
    signal_routes: [
      {"state.merge_metadata", MergeMetadataAction},
      {"state.replace_all", ReplaceAllAction},
      {"state.clear_temp", ClearTempDataAction},
      {"state.set_nested", SetNestedValueAction},
      {"state.delete_nested", DeleteNestedValueAction}
    ]

  @doc false
  @spec plugin_specs() :: nonempty_list(Jido.Plugin.Spec.t())
  def plugin_specs, do: super()
end
