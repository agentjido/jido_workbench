defmodule AgentJido.Blog.TagAlias do
  @moduledoc """
  Canonical redirect mapping for legacy blog tags.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias AgentJido.Blog.Taxonomy
  alias AgentJido.Repo

  schema "blog_tag_aliases" do
    field :legacy_tag, :string
    field :canonical_tag, :string

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: integer() | nil,
          legacy_tag: String.t() | nil,
          canonical_tag: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @spec canonical_tag_for(String.t()) :: String.t() | nil
  def canonical_tag_for(legacy_tag) when is_binary(legacy_tag) do
    normalized = Taxonomy.normalize_tag_token(legacy_tag)

    if normalized in [nil, ""] do
      nil
    else
      db_alias =
        Repo.one(
          from alias_row in __MODULE__,
            where: alias_row.legacy_tag == ^normalized,
            select: alias_row.canonical_tag
        )

      fallback_alias = Map.get(Taxonomy.default_tag_aliases(), normalized)
      canonical = db_alias || fallback_alias

      case Taxonomy.canonical_tag(canonical) do
        value when is_binary(value) and value != "" and value != normalized -> value
        _ -> nil
      end
    end
  rescue
    _ -> nil
  end

  def canonical_tag_for(_legacy_tag), do: nil

  @spec upsert(String.t(), String.t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def upsert(legacy_tag, canonical_tag)
      when is_binary(legacy_tag) and is_binary(canonical_tag) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    normalized_legacy = Taxonomy.normalize_tag_token(legacy_tag)
    normalized_canonical = Taxonomy.canonical_tag(canonical_tag)

    %__MODULE__{}
    |> changeset(%{legacy_tag: normalized_legacy, canonical_tag: normalized_canonical})
    |> Repo.insert(
      on_conflict: [
        set: [
          canonical_tag: normalized_canonical,
          updated_at: now
        ]
      ],
      conflict_target: [:legacy_tag]
    )
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(alias_row, attrs) do
    alias_row
    |> cast(attrs, [:legacy_tag, :canonical_tag])
    |> validate_required([:legacy_tag, :canonical_tag])
    |> validate_length(:legacy_tag, min: 1)
    |> validate_length(:canonical_tag, min: 1)
    |> unique_constraint(:legacy_tag)
  end
end
