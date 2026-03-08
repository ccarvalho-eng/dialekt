defmodule Dialekt.Repo.Migrations.CreateLearningConfigs do
  use Ecto.Migration

  def change do
    create table(:learning_configs) do
      add(:name, :string, null: false)
      add(:native_language_code, :string, null: false)
      add(:target_language_code, :string, null: false)
      add(:cefr_level_code, :string, null: false)
      add(:register_code, :string, null: false)

      timestamps(type: :utc_datetime)
    end
  end
end
