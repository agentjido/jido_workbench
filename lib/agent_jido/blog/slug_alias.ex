defmodule AgentJido.Blog.SlugAlias do
  @moduledoc """
  Canonical redirect mapping for legacy blog slugs.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias AgentJido.Repo

  schema "blog_slug_aliases" do
    field :legacy_slug, :string
    field :canonical_slug, :string

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: integer() | nil,
          legacy_slug: String.t() | nil,
          canonical_slug: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @spec canonical_slug_for(String.t()) :: String.t() | nil
  def canonical_slug_for(legacy_slug) when is_binary(legacy_slug) do
    normalized = String.trim(legacy_slug)

    case Repo.one(from alias_row in __MODULE__, where: alias_row.legacy_slug == ^normalized, select: alias_row.canonical_slug) do
      value when is_binary(value) and value != "" -> value
      _ -> nil
    end
  rescue
    _ -> nil
  end

  def canonical_slug_for(_legacy_slug), do: nil

  @spec upsert(String.t(), String.t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def upsert(legacy_slug, canonical_slug)
      when is_binary(legacy_slug) and is_binary(canonical_slug) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    normalized_legacy = String.trim(legacy_slug)
    normalized_canonical = String.trim(canonical_slug)

    %__MODULE__{}
    |> changeset(%{legacy_slug: normalized_legacy, canonical_slug: normalized_canonical})
    |> Repo.insert(
      on_conflict: [
        set: [
          canonical_slug: normalized_canonical,
          updated_at: now
        ]
      ],
      conflict_target: [:legacy_slug]
    )
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(alias_row, attrs) do
    alias_row
    |> cast(attrs, [:legacy_slug, :canonical_slug])
    |> validate_required([:legacy_slug, :canonical_slug])
    |> validate_length(:legacy_slug, min: 1)
    |> validate_length(:canonical_slug, min: 1)
    |> unique_constraint(:legacy_slug)
  end
end
