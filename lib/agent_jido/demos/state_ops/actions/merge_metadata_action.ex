defmodule AgentJido.Demos.StateOps.MergeMetadataAction do
  @moduledoc """
  Merges metadata using `StateOp.SetState`.
  """

  alias Jido.Agent.StateOp

  use Jido.Action,
    name: "merge_metadata",
    description: "Merges metadata into state",
    schema: [
      metadata: [type: :map, required: true]
    ]

  @impl true
  def run(%{metadata: metadata}, _context) do
    {:ok, %{}, %StateOp.SetState{attrs: %{metadata: metadata}}}
  end
end
