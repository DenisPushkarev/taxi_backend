defmodule TaxiBackend do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Taxi.Web.Router, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: Taxi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
