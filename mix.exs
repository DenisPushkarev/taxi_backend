defmodule TaxiBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :taxi_backend,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {TaxiBackend, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.8"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.3"},
      {:joken, "~> 2.2"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:bcrypt_elixir, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:geo_postgis, "~> 3.1"},
      {:geo, "~> 3.3"}
    ]
  end

  defp aliases do
    [
      "ecto.init": ["ecto.drop", "ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs", "test"]
    ]
  end
end
