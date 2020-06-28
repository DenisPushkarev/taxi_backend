defmodule Taxi.Web.Plugs.Access do
  import Plug.Conn
  @endpoints ["manager", "driver"]

  def init(opts), do: opts

  def validate_access!(conn = %{path_info: [p | _], assigns: %{role: r}}, _)
      when p in @endpoints do
    if r == p do
      conn
    else
      conn
      |> send_deny
      |> Plug.Conn.halt()
    end
  end

  def validate_access!(conn = %{path_info: [p | _]}, _) when p in @endpoints do
    conn
    |> send_auth()
    |> Plug.Conn.halt()
  end

  def validate_access!(conn, _), do: conn

  def call(conn, opts) do
    validate_access!(conn, opts)
  end

  defp send_deny(conn), do: send_resp(conn, 401, Jason.encode!(%{error: "Access denied"}))
  defp send_auth(conn), do: send_resp(conn, 403, Jason.encode!(%{error: "Unauthenticated"}))
end
