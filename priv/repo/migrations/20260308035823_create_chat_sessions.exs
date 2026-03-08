defmodule Dialekt.Repo.Migrations.CreateChatSessions do
  use Ecto.Migration

  def change do
    create table(:chat_sessions) do
      add(:config_id, references(:learning_configs, on_delete: :delete_all), null: false)

      add(:messages, :jsonb, null: false, default: "[]")

      timestamps(type: :utc_datetime)
    end

    create(index(:chat_sessions, [:config_id]))
  end
end
