defmodule AgentJido.QueryLogs.QueryLog do
  @moduledoc """
  Persistence model for content assistant query activity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias AgentJido.Analytics.Redactor

  @source_values ["content_assistant"]
  @status_values ["submitted", "success", "no_results", "error", "challenge"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "query_logs" do
    field :source, :string
    field :channel, :string
    field :query, :string
    field :query_hash, :string
    field :status, :string, default: "submitted"
    field :results_count, :integer, default: 0
    field :latency_ms, :integer
    field :visitor_id, :string
    field :session_id, :string
    field :path, :string
    field :referrer_host, :string
    field :metadata, :map, default: %{}

    belongs_to :user, AgentJido.Accounts.User

    timestamps()
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          source: String.t(),
          channel: String.t(),
          query: String.t(),
          query_hash: String.t() | nil,
          status: String.t(),
          results_count: non_neg_integer(),
          latency_ms: non_neg_integer() | nil,
          visitor_id: String.t() | nil,
          session_id: String.t() | nil,
          path: String.t() | nil,
          referrer_host: String.t() | nil,
          user_id: Ecto.UUID.t() | nil,
          metadata: map(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @doc """
  Returns the set of allowed source values.
  """
  @spec source_values() :: [String.t()]
  def source_values, do: @source_values

  @doc """
  Returns the set of allowed status values.
  """
  @spec status_values() :: [String.t()]
  def status_values, do: @status_values

  @doc """
  Changeset for creating a query log entry.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = query_log, attrs) when is_map(attrs) do
    query_log
    |> cast(attrs, [
      :source,
      :channel,
      :query,
      :query_hash,
      :status,
      :results_count,
      :latency_ms,
      :visitor_id,
      :session_id,
      :path,
      :referrer_host,
      :user_id,
      :metadata
    ])
    |> normalize_query()
    |> validate_required([:source, :channel, :query, :status])
    |> validate_inclusion(:source, @source_values)
    |> validate_inclusion(:status, @status_values)
    |> validate_length(:channel, min: 2, max: 100)
    |> validate_length(:query, min: 1, max: 2000)
    |> validate_length(:query_hash, min: 64, max: 64)
    |> validate_length(:visitor_id, min: 8, max: 128)
    |> validate_length(:session_id, min: 8, max: 128)
    |> validate_length(:path, max: 500)
    |> validate_length(:referrer_host, max: 255)
    |> validate_number(:results_count, greater_than_or_equal_to: 0)
    |> validate_number(:latency_ms, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
  end

  @doc """
  Changeset for updating execution outcomes on an existing log.
  """
  @spec finalize_changeset(t(), map()) :: Ecto.Changeset.t()
  def finalize_changeset(%__MODULE__{} = query_log, attrs) when is_map(attrs) do
    query_log
    |> cast(attrs, [:status, :results_count, :latency_ms, :metadata])
    |> validate_inclusion(:status, @status_values)
    |> validate_number(:results_count, greater_than_or_equal_to: 0)
    |> validate_number(:latency_ms, greater_than_or_equal_to: 0)
  end

  defp normalize_query(changeset) do
    normalized =
      changeset
      |> get_change(:query)
      |> Redactor.normalize_query()

    redacted = Redactor.redact_query(normalized)

    changeset
    |> put_change(:query, redacted)
    |> put_change(:query_hash, Redactor.query_hash(normalized))
  end
end
