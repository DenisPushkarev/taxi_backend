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
        with {:ok, data = %{token: _, role: _, uuid: _}} <-
               Authorization.authorize(login, password) do
          send_resp(conn, 200, Jason.encode!(data))
        else
          :invalid_login -> send_resp(conn, 401, Jason.encode!(%{error: "login failed"}))
        end

      _ ->
        conn |> invalid_request()
    end
  end

  get "/driver/task/find" do
    case conn.query_params do
      %{"lat" => lat_str, "lng" => lng_str} ->
        with {lat, _} <- Float.parse(lat_str),
             {lng, _} <- Float.parse(lng_str),
             {:ok, t = %{tasks: _}} <- Taxi.Task.find_nearest(lat, lng) do
          conn |> send_resp(200, Jason.encode!(t))
        else
          _ ->
            conn |> invalid_request()
        end

      _ ->
        conn |> invalid_request()
    end
  end

  put "driver/task/:task_id/start" do
    driver_id = conn |> Map.fetch!(:assigns) |> Map.fetch!(:uuid)
    tt = Taxi.Task.assign_driver(driver_id, task_id)

    case tt do
      :ok ->
        conn |> send_resp(202, Jason.encode!(%{task_id: task_id}))

      :not_available ->
        conn |> send_resp(404, Jason.encode!(%{error: "Task has been taken"}))

      _ ->
        conn |> invalid_request()
    end
  end

  put "driver/task/:task_id/finish" do
    driver_id = conn |> Map.fetch!(:assigns) |> Map.fetch!(:uuid)
    tt = Taxi.Task.finish(driver_id, task_id)

    case tt do
      :ok ->
        conn |> send_resp(202, Jason.encode!(%{task_id: task_id, message: "thank you!"}))

      :not_available ->
        conn |> send_resp(404, Jason.encode!(%{error: "Task is not available"}))

      _ ->
        conn |> invalid_request()
    end
  end

  ########### manager routines #################

  post "/manager/task/new" do
    case conn.body_params do
      %{"start_lat" => slt, "start_lng" => slg, "end_lat" => elt, "end_lng" => elg}
      when is_float(slt) and is_float(slg) and is_float(elt) and is_float(elg) ->
        with {:ok, uuid} <-
               Taxi.Task.add(%{
                 start: %Geo.Point{coordinates: {slt, slg}, srid: 4326},
                 end: %Geo.Point{coordinates: {elt, elg}, srid: 4326}
               }) do
          conn |> send_resp(202, Jason.encode!(%{task_id: uuid}))
        else
          _ -> conn |> send_resp(501, Jason.encode!(%{error: "Can not insert new task"}))
        end

      _ ->
        conn |> invalid_request
    end
  end

  get "/manager/task/:task_id/get" do
    case Taxi.Task.get(task_id) do
      :not_found ->
        conn |> send_resp(404, Jason.encode!(%{error: "Task not found"}))

      t = %{uuid: _} ->
        r =
          t
          |> Map.take([:start_lat, :start_lng, :end_lat, :end_lng, :status, :driver])
          |> Map.put(:task_id, t.uuid)

        conn |> send_resp(202, Jason.encode!(r))
    end
  end

  get "/manager/task/list" do
    case Taxi.Task.list(%{}) do
      {:ok, %{total: total, tasks: tasks_list}} ->
        conn |> send_resp(202, Jason.encode!(%{tasks: tasks_list, total: total}))

      _ ->
        conn |> send_resp(501, Jason.encode!(%{error: "Something went wrong"}))
    end
  end

  defp invalid_request(conn),
    do: send_resp(conn, 400, Jason.encode!(%{error: "Invalid request parameters"}))

  match _ do
    send_resp(conn, 404, "not found")
  end
end
