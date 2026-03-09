defmodule Dialekt.Repo.Migrations.AddStartersToConfigs do
  use Ecto.Migration

  def change do
    alter table(:learning_configs) do
      add(:starters, {:array, :string}, default: [])
    end
  end
end
