defmodule AgentJido.Repo.Migrations.AddFirstPartyAnalytics do
  use Ecto.Migration

  def change do
    alter table(:query_logs) do
      add(:visitor_id, :string)
      add(:session_id, :string)
      add(:user_id, references(:users, type: :binary_id, on_delete: :nilify_all))
      add(:path, :string)
      add(:referrer_host, :string)
      add(:query_hash, :string)
      add(:latency_ms, :integer)
    end

    create(index(:query_logs, [:query_hash, :inserted_at]))
    create(index(:query_logs, [:visitor_id, :inserted_at]))
    create(index(:query_logs, [:session_id, :inserted_at]))
    create(index(:query_logs, [:user_id, :inserted_at]))

    create table(:analytics_events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:event, :string, null: false)
      add(:source, :string, null: false)
      add(:channel, :string, null: false)
      add(:path, :string, null: false)
      add(:section_id, :string)
      add(:target_url, :text)
      add(:rank, :integer)
      add(:feedback_value, :string)
      add(:feedback_note, :text)
      add(:query_log_id, references(:query_logs, type: :binary_id, on_delete: :nilify_all))
      add(:visitor_id, :string, null: false)
      add(:session_id, :string, null: false)
      add(:user_id, references(:users, type: :binary_id, on_delete: :nilify_all))
      add(:metadata, :map, null: false, default: %{})

      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create(index(:analytics_events, [:inserted_at]))
    create(index(:analytics_events, [:event, :inserted_at]))
    create(index(:analytics_events, [:path, :inserted_at]))
    create(index(:analytics_events, [:query_log_id]))
    create(index(:analytics_events, [:visitor_id, :inserted_at]))
    create(index(:analytics_events, [:session_id, :inserted_at]))
    create(index(:analytics_events, [:user_id, :inserted_at]))
  end
end
