defmodule Taxi.Web.Router do
  use Plug.Router
  use Plug.ErrorHandler
  alias Taxi.Web.Plugs.{Authentication, Access}
  alias Taxi.Web.Auth.Authorization
  alias Taxi.Task

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
          j_resp(conn, 200, data)
        else
          :invalid_login -> j_resp(conn, 401, %{error: "login failed"})
        end

      _ ->
        conn |> invalid_request()
    end
  end

  ########### driver routines #################
  get "/driver/task/find" do
    case conn.query_params do
      %{"lat" => lat_str, "lng" => lng_str} ->
        with {lat, _} <- Float.parse(lat_str),
             {lng, _} <- Float.parse(lng_str),
             {:ok, %{tasks: tasks}} <- Task.find_nearest(lat, lng),
             result <- Enum.map(tasks, &Map.drop(&1, [:driver])) do
          j_resp(conn, 200, %{tasks: result})
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
    result = Task.assign_driver(driver_id, task_id)

    case result do
      :ok ->
        conn |> j_resp(202, %{task_id: task_id})

      {:error, :already_taken} ->
        j_resp(conn, 404, %{error: "Task is already taken"})

      {:error, :driver_has_processing} ->
        j_resp(conn, 400, %{error: "Driver already has assigned task"})

      _ ->
        conn |> invalid_request()
    end
  end

  put "driver/task/:task_id/finish" do
    driver_id = conn |> Map.fetch!(:assigns) |> Map.fetch!(:uuid)
    tt = Task.finish(driver_id, task_id)

    case tt do
      :ok ->
        conn |> j_resp(202, %{task_id: task_id, message: "thank you!"})

      :not_available ->
        conn |> j_resp(404, %{error: "Task is not available"})

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
               Task.add(%{
                 start_point: {slt, slg},
                 end_point: {elt, elg},
                 note: Map.get(conn.body_params, "note")
               }) do
          conn |> j_resp(202, %{task_id: uuid})
        else
          _ -> conn |> j_resp(501, %{error: "Can not insert new task"})
        end

      _ ->
        conn |> invalid_request
    end
  end

  get "/manager/task/:task_id/get" do
    case Task.get(task_id) do
      :not_found ->
        conn |> j_resp(404, %{error: "Task not found"})

      task ->
        conn |> j_resp(202, task)
    end
  end

  get "/manager/task/list" do
    case Task.list(%{}) do
      {:ok, %{total: total, tasks: tasks_list}} ->
        conn |> j_resp(202, %{tasks: tasks_list, total: total})

      _ ->
        conn |> j_resp(501, %{error: "Something went wrong"})
    end
  end

  ########### utils #################
  defp invalid_request(conn),
    do: j_resp(conn, 400, %{error: "Invalid request parameters"})

  match _ do
    j_resp(conn, 404, %{error: "not found"})
  end

  defp j_resp(conn, code, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(code, Jason.encode!(body))
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
    IO.inspect({:ERROR, kind, reason})

    case reason do
      %Plug.Parsers.ParseError{} -> j_resp(conn, 400, %{error: "Invalid request data"})
      _ -> j_resp(conn, 500, %{error: "Something went wrong"})
    end
  end
end
