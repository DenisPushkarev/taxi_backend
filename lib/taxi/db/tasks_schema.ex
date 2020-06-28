defmodule Taxi.Db.Tasks do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "tasks" do
    field(:start_lat, :float)
    field(:start_lng, :float)
    field(:end_lat, :float)
    field(:end_lng, :float)
    field(:status, :integer)
    field(:driver, :binary_id)
    timestamps()
  end
end
