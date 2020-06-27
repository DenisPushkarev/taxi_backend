defmodule Taxi.Web.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Taxi.Web.Router.init([])

  test "if wen endpoint is working" do
    conn = conn(:get, "/ping")
    conn = Taxi.Web.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end
end
