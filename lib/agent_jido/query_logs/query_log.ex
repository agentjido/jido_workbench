defmodule AgentJido.QueryLogs.QueryLog do
  @moduledoc """
  Persistence model for Ask AI and search query activity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @source_values ["ask_ai", "search"]
  @status_values ["submitted", "success", "no_results", "error", "challenge"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "query_logs" do
    field :source, :string
    field :channel, :string
    field :query, :string
    field :status, :string, default: "submitted"
    field :results_count, :integer, default: 0
    field :metadata, :map, default: %{}

    timestamps()
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          source: String.t(),
          channel: String.t(),
          query: String.t(),
          status: String.t(),
          results_count: non_neg_integer(),
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
    |> cast(attrs, [:source, :channel, :query, :status, :results_count, :metadata])
    |> normalize_query()
    |> validate_required([:source, :channel, :query, :status])
    |> validate_inclusion(:source, @source_values)
    |> validate_inclusion(:status, @status_values)
    |> validate_length(:channel, min: 2, max: 100)
    |> validate_length(:query, min: 1, max: 2000)
    |> validate_number(:results_count, greater_than_or_equal_to: 0)
  end

  @doc """
  Changeset for updating execution outcomes on an existing log.
  """
  @spec finalize_changeset(t(), map()) :: Ecto.Changeset.t()
  def finalize_changeset(%__MODULE__{} = query_log, attrs) when is_map(attrs) do
    query_log
    |> cast(attrs, [:status, :results_count, :metadata])
    |> validate_inclusion(:status, @status_values)
    |> validate_number(:results_count, greater_than_or_equal_to: 0)
  end

  defp normalize_query(changeset) do
    update_change(changeset, :query, &String.trim/1)
  end
end
