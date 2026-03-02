defmodule AgentJido.ContentIngest do
  @moduledoc """
  Local content ingestion entrypoint for Arcana.

  Builds an inventory from first-party content sources and synchronizes
  Arcana collections/documents in an idempotent way.

  Also exposes ingestion audit helpers for:

    * expected snapshot generation
    * ingested snapshot generation
    * expected-vs-ingested comparison
  """

  alias AgentJido.ContentIngest.Audit
  alias AgentJido.ContentIngest.Ingestor

  @doc """
  Synchronize managed content into Arcana.

  See `AgentJido.ContentIngest.Ingestor.sync/1` for supported options.
  """
  @spec sync(keyword()) :: map()
  def sync(opts \\ []), do: Ingestor.sync(opts)

  @doc """
  Builds and compares expected + ingested snapshots.
  """
  @spec audit(keyword()) :: Audit.report()
  def audit(opts \\ []), do: Audit.audit(opts)

  @doc """
  Returns the expected snapshot from local inventory.
  """
  @spec expected_snapshot(keyword()) :: [Audit.expected_source()]
  def expected_snapshot(opts \\ []), do: Audit.expected_sources(opts)

  @doc """
  Returns the currently ingested snapshot from Arcana.
  """
  @spec ingested_snapshot(keyword()) :: [Audit.ingested_source()]
  def ingested_snapshot(opts \\ []), do: Audit.ingested_sources(opts)

  @doc """
  Returns audit status for a single `source_id`.
  """
  @spec source_report(String.t(), keyword()) :: Audit.comparison_row() | nil
  def source_report(source_id, opts \\ []), do: Audit.source_report(source_id, opts)
end
