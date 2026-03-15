defmodule AgentJido.Demos.PersistenceStorageAgent do
  @moduledoc """
  Demo agent for persistence round-trips with `Jido.Persist`.
  """

  alias AgentJido.Demos.PersistenceStorage.{AddNoteAction, IncrementAction}

  use Jido.Agent,
    name: "persistence_storage_agent",
    description: "Demonstrates hibernate/thaw with ETS storage",
    schema: [
      counter: [type: :integer, default: 0],
      status: [type: :atom, default: :idle],
      notes: [type: {:list, :string}, default: []]
    ],
    signal_routes: [
      {"counter.increment", IncrementAction},
      {"notes.add", AddNoteAction}
    ]

  @doc false
  @spec plugin_specs() :: nonempty_list(Jido.Plugin.Spec.t())
  def plugin_specs, do: super()
end
