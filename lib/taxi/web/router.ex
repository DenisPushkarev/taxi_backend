defmodule Taxi.Web.Router do
  use Plug.Router
  alias Taxi.Web.Plugs.{Authentication, Access}
  alias Taxi.Web.Auth.Authorization

  plug(Plug.Logger)
  plug(Authentication)
  plug(Access)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get("/ping", do: send_resp(conn, 200, "pong"))

  post "/login" do
    case conn.body_params do
      %{"login" => login, "password" => password} ->
        with {:ok, data = %{token: _, role: _, uuid: _}} <- Authorization.authorize(login, password) do
          send_resp(conn, 200, Jason.encode!(data))
        else
          :invalid_login -> send_resp(conn, 401, Jason.encode!(%{error: "login failed"}))
        end

      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "invalid request params"}))
    end
  end

  get "/driver/tasks" do
    conn |> send_resp(200, Jason.encode!(%{im: "driver", your: conn.assigns}))
  end
########### manager routines #################

  get "/manager/tasks" do
    conn |> send_resp(200, Jason.encode!(%{im: "manager", your: conn.assigns}))
  end

  post "/manager/task/new" do
    conn
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

end
