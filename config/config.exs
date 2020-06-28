use Mix.Config
config :taxi_backend, ecto_repos: [Taxi.Repo]
import_config "#{Mix.env()}.exs"
