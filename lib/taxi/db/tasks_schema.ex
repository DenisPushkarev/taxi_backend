defmodule Taxi.Db.Tasks do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "tasks" do
    field(:start_point, Geo.PostGIS.Geometry)
    field(:end_point, Geo.PostGIS.Geometry)
    field(:note, :string)
    field(:status, :string, default: "new")
    field(:driver, :binary_id)
    timestamps()
  end
end
