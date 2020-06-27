defmodule TaxiBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :taxi_backend,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:joken, "~> 2.2"}
    ]
  end
end
