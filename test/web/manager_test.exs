defmodule Taxi.Web.ManagerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Taxi.Web.Router.init([])

  test "if manager can add task" do
    conn = authenticate() |> add_test_task()
    assert conn.state == :sent
    assert conn.status == 202
    assert %{"task_id" => _} = Jason.decode!(conn.resp_body)
  end

  test "if manager can get task" do
    token = authenticate()
    conn = add_test_task(token)
    %{"task_id" => task_id} = Jason.decode!(conn.resp_body)

    task = get_task(task_id, token)
    # Assert the response and status
    assert task.state == :sent
    assert task.status == 202

    assert %{
             "driver" => _,
             "end_lat" => _,
             "end_lng" => _,
             "start_lat" => _,
             "start_lng" => _,
             "status" => _,
             "task_id" => _
           } = Jason.decode!(task.resp_body)
  end

  test "if manager can get list of tasks" do
    token = authenticate()
    conn = add_test_task(token)
    %{"task_id" => task_id} = Jason.decode!(conn.resp_body)

    conn =
      conn(:get, "/manager/task/list")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Taxi.Web.Router.call(@opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 202

    assert %{"tasks" => _} = Jason.decode!(conn.resp_body)
  end

  defp authenticate() do
    conn = conn(:post, "/login", %{login: "manager", password: "manager"})

    %{state: :sent, status: 200, resp_body: body} = Taxi.Web.Router.call(conn, @opts)

    %{"token" => token} = Jason.decode!(body)
    token
  end

  defp add_test_task(token) do
    conn =
      conn(:post, "/manager/task/new", %{
        start_lat: 45.047130,
        start_lng: 38.974260,
        end_lat: 45.099950,
        end_lng: 38.971620
      })
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Taxi.Web.Router.call(@opts)
  end

  defp get_task(task_id, token) do
    conn =
      conn(:get, "/manager/task/#{task_id}/get")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Taxi.Web.Router.call(@opts)
  end
end
