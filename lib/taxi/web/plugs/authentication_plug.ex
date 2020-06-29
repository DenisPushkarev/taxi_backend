defmodule Taxi.Web.Plugs.Authentication do
  import Plug.Conn
  alias Taxi.Web.Auth.Token, as: TaxiToken

  def init(opts), do: opts

  defp authenticate({conn, "Bearer " <> token}) do
    case TaxiToken.verify_and_validate(token) do
      {:ok, %{"role" => role, "uuid" => uuid}} ->
        conn |> assign(:role, role) |> assign(:uuid, uuid)

      _ ->
        conn
    end
  end

  defp authenticate({conn}) do
    conn
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [token] -> {conn, token}
      _ -> {conn}
    end
  end

  def call(conn, _opts) do
    conn
    |> get_auth_header
    |> authenticate
  end
end
