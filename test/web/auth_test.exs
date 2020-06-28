defmodule Taxi.Web.AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Taxi.Web.Router.init([])

  test "if driver user can login" do
    conn = conn(:post, "/login", %{login: "driver", password: "driver"})
    conn = Taxi.Web.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"token" => _, "role" => "driver", "uuid" => _} = Jason.decode!(conn.resp_body)
  end

  test "if driver user can not login with wrong password" do
    conn = conn(:post, "/login", %{login: "driver", password: "somethingwrong"})
    conn = Taxi.Web.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 401
    assert %{"error" => "login failed"} = Jason.decode!(conn.resp_body)
  end
end
