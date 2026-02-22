defmodule AgentJido.Repo.Migrations.CreateQueryLogs do
  use Ecto.Migration

  def change do
    create table(:query_logs, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:source, :string, null: false)
      add(:channel, :string, null: false)
      add(:query, :text, null: false)
      add(:status, :string, null: false, default: "submitted")
      add(:results_count, :integer, null: false, default: 0)
      add(:metadata, :map, null: false, default: %{})

      timestamps()
    end

    create(index(:query_logs, [:inserted_at]))
    create(index(:query_logs, [:source, :inserted_at]))
    create(index(:query_logs, [:status, :inserted_at]))
    create(index(:query_logs, [:channel, :inserted_at]))
  end
end
