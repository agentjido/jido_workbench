defmodule AgentJido.ContentIngest do
  @moduledoc """
  Local content ingestion entrypoint for Arcana.

  Builds an inventory from first-party content sources and synchronizes
  Arcana collections/documents in an idempotent way.
  """

  alias AgentJido.ContentIngest.Ingestor

  @doc """
  Synchronize managed content into Arcana.

  See `AgentJido.ContentIngest.Ingestor.sync/1` for supported options.
  """
  @spec sync(keyword()) :: map()
  def sync(opts \\ []), do: Ingestor.sync(opts)
end
