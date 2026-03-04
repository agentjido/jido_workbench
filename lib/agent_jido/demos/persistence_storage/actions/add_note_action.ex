defmodule AgentJido.Demos.PersistenceStorage.AddNoteAction do
  @moduledoc """
  Appends a note to persisted state.
  """

  use Jido.Action,
    name: "add_note",
    description: "Adds a note",
    schema: [
      note: [type: :string, required: true]
    ]

  @impl true
  def run(%{note: note}, context) do
    notes = Map.get(context.state, :notes, [])
    {:ok, %{notes: notes ++ [note], status: :updated}}
  end
end
