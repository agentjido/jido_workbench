defmodule AgentJido.Demos.PluginBasics.AddNoteAction do
  @moduledoc """
  Appends a note entry to plugin-managed state.
  """

  use Jido.Action,
    name: "add_note",
    description: "Adds a note entry",
    schema: [
      text: [type: :string, required: true]
    ]

  @impl true
  def run(%{text: text}, context) do
    notes = get_in(context.state, [:notes, :entries]) || []
    note = %{text: text, added_at: DateTime.utc_now()}
    {:ok, %{notes: %{entries: [note | notes]}}}
  end
end
