defmodule Taxi.Db.Users do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  # weather is the DB table
  schema "users" do
    field(:login, :string)
    field(:hashed_password, :string)
    field(:role, :string)
    timestamps()
  end
end
