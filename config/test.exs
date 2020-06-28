use Mix.Config
config :joken, default_signer: "secret"

config :taxi_backend, Taxi.Repo,
  database: "taxi",
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: "localhost",
  port: "5432"
