defmodule AgentJido.Demos.PluginBasics.ClearNotesAction do
  @moduledoc """
  Clears all note entries from plugin-managed state.
  """

  use Jido.Action,
    name: "clear_notes",
    description: "Clears note entries",
    schema: []

  @impl true
  def run(_params, _context) do
    {:ok, %{notes: %{entries: []}}}
  end
end
