defmodule AgentJido.ContentIngest.Source do
  @moduledoc """
  Normalized content source record for Arcana ingestion.
  """

  @enforce_keys [:source_id, :collection, :text, :metadata]
  defstruct [:source_id, :collection, :collection_description, :text, :metadata]

  @type t :: %__MODULE__{
          source_id: String.t(),
          collection: String.t(),
          collection_description: String.t() | nil,
          text: String.t(),
          metadata: map()
        }
end
