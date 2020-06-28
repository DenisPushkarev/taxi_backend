defmodule Taxi.Repo do
  use Ecto.Repo,
    otp_app: :taxi_backend,
    adapter: Ecto.Adapters.Postgres
end
