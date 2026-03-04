defmodule AgentJido.Demos.PersistenceStorageAgent do
  @moduledoc """
  Demo agent for persistence round-trips with `Jido.Persist`.
  """

  alias AgentJido.Demos.PersistenceStorage.{IncrementAction, AddNoteAction}

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
end
