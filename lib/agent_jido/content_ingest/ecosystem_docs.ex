defmodule AgentJido.ContentIngest.EcosystemDocs do
  @moduledoc """
  Background-managed HexDocs ingestion for published ecosystem packages.
  """

  alias AgentJido.ContentIngest.EcosystemDocs.{Crawler, Sync}

  @spec collection() :: String.t()
  def collection, do: Sync.collection()

  @spec managed_by() :: String.t()
  def managed_by, do: Sync.managed_by()

  @doc """
  Triggers a background full crawl via the supervised crawler.
  """
  @spec sync() :: :ok | {:error, term()}
  def sync, do: Crawler.sync()

  @doc """
  Triggers a background crawl for one ecosystem package id.
  """
  @spec sync_package(String.t()) :: :ok | {:error, term()}
  def sync_package(package_id), do: Crawler.sync_package(package_id)

  @doc """
  Returns the current crawler status.
  """
  @spec status() :: map()
  def status, do: Crawler.status()

  @doc """
  Runs a synchronous crawl directly in the current process.

  This is used by CLI tasks and tests.
  """
  @spec sync_now(keyword()) :: map()
  def sync_now(opts \\ []), do: Sync.sync(opts)

  @doc """
  Runs a synchronous crawl for one package directly in the current process.
  """
  @spec sync_package_now(String.t(), keyword()) :: map()
  def sync_package_now(package_id, opts \\ []), do: Sync.sync_package(package_id, opts)

  @doc """
  Returns a persisted snapshot of the managed HexDocs corpus.
  """
  @spec snapshot(keyword()) :: map()
  def snapshot(opts \\ []), do: Sync.snapshot(opts)
end
