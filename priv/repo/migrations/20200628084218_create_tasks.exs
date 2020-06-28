defmodule Taxi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add(:start_lat, :float)
      add(:start_lng, :float)
      add(:end_lat, :float)
      add(:end_lng, :float)
      add(:status, :string)
      add(:driver, :binary_id)

      timestamps()
    end

    create unique_index(:tasks, [:driver])
    create index(:tasks, [:status])
  end
end
