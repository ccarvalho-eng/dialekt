defmodule Dialekt.Repo.Migrations.CreateMistakes do
  use Ecto.Migration

  def change do
    create table(:mistakes) do
      add(:config_id, references(:learning_configs, on_delete: :delete_all), null: false)
      add(:original_input, :text, null: false)
      add(:corrected_form, :text, null: false)
      add(:explanation, :text)
      add(:learned_at, :utc_datetime)

      timestamps(type: :utc_datetime)
    end

    create(index(:mistakes, [:config_id, :learned_at, :inserted_at]))
  end
end
