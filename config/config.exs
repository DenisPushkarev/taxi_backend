use Mix.Config
config :taxi_backend, ecto_repos: [Taxi.Repo]

config :taxi_backend, Taxi.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Taxi.PostgresTypes

import_config "#{Mix.env()}.exs"
