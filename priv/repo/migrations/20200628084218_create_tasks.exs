defmodule Taxi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis")

    create table(:tasks, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:status, :string)
      add(:note, :string)
      add(:driver, :binary_id)
      timestamps()
    end

    execute("SELECT AddGeometryColumn ('tasks', 'start_point', 4326, 'POINT', 2);")
    execute("SELECT AddGeometryColumn ('tasks', 'end_point', 4326, 'POINT', 2);")

    create(index(:tasks, [:driver]))
    create(index(:tasks, [:status]))
  end

  def down do
    drop(index(:tasks, [:driver]))
    drop(index(:tasks, [:status]))
    drop(table(:tasks))
    execute("DROP EXTENSION IF EXISTS postgis")
  end
end
