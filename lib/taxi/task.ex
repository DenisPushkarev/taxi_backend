defmodule Taxi.Task do
  import Ecto.Query
  import Geo.PostGIS
  alias Taxi.Db.Tasks
  alias Taxi.Repo

  def add(%{start: geom_start, end: geom_end}) do
    task = %Tasks{
      start_point: geom_start,
      end_point: geom_end,
      uuid: UUID.uuid4(),
      status: "new"
    }

    with {:ok, %Tasks{uuid: uuid}} <- Repo.insert(task) do
      {:ok, uuid}
    else
      _ -> :error
    end
  end

  def get(task_id) when is_binary(task_id) do
    case Tasks |> Repo.get_by(uuid: task_id) do
      t = %Tasks{uuid: ^task_id} ->
        t

      _ ->
        :not_found
    end
  end

  def list(_opts) do
    query = from(t in Tasks, where: fragment("? != ?", t.status, "deleted"))
    total = query |> count()
    tasks = query |> Repo.all()

    r =
      tasks
      |> Enum.reduce([], fn %{
                              uuid: uuid,
                              driver: driver,
                              status: status,
                              start_point: %Geo.Point{coordinates: {start_lat, start_lng}},
                              end_point: %Geo.Point{coordinates: {end_lat, end_lng}}
                            },
                            acc ->
        acc ++
          [
            %{
              task_id: uuid,
              status: status,
              driver: driver,
              start_lat: start_lat,
              start_lng: start_lng,
              end_lat: end_lat,
              end_lng: end_lng,
            }
          ]
      end)

    {:ok, %{tasks: r, total: total}}
  end

  defp count(query) do
    query |> select([:uuid]) |> Repo.aggregate(:count, :uuid)
  end

  def assign_driver(driver_id, task_id) when is_binary(driver_id) and is_binary(task_id) do
    from(task in Tasks,
      where: task.uuid == ^task_id and task.status == "new",
      update: [set: [driver: ^driver_id, status: "processing"]]
    )
    |> Repo.update_all([])

    tasks =
      from(task in Tasks, where: task.uuid == ^task_id and task.driver == ^driver_id)
      |> Repo.all()

    case tasks do
      [%Taxi.Db.Tasks{driver: ^driver_id, uuid: ^task_id}] -> :ok
      [] -> :not_available
      _ -> :error
    end
  end

  def finish(driver_id, task_id) when is_binary(driver_id) and is_binary(task_id) do
    from(task in Tasks,
      where: task.uuid == ^task_id and task.status == "processing" and task.driver == ^driver_id,
      update: [set: [status: "finished"]]
    )
    |> Repo.update_all([])

    tasks =
      from(task in Tasks,
        where: task.uuid == ^task_id and task.driver == ^driver_id and task.status == "finished"
      )
      |> Repo.all()

    case tasks do
      [%Taxi.Db.Tasks{driver: ^driver_id, uuid: ^task_id}] -> :ok
      [] -> :not_available
      _ -> :error
    end
  end

  def find_nearest(lat, lng, _opts \\ %{}) when is_float(lat) and is_float(lng) do
    geom = %Geo.Point{coordinates: {lat, lng}, srid: 4326}

    query =
      from(tasks in Tasks,
        limit: 5,
        where: tasks.status == "new",
        order_by: st_distancesphere(tasks.start_point, ^geom),
        select:
          {tasks.uuid, tasks.start_point, tasks.end_point,
           st_distancesphere(tasks.start_point, ^geom)}
      )

    tasks_with_geom = query |> Repo.all()

    tasks =
      Enum.reduce(tasks_with_geom, [], fn
        {
          uuid,
          %Geo.Point{coordinates: {start_lat, start_lng}},
          %Geo.Point{coordinates: {end_lat, end_lng}},
          distance
        },
        acc ->
          acc ++
            [
              %{
                task_id: uuid,
                start_lat: start_lat,
                start_lng: start_lng,
                end_lat: end_lat,
                end_lng: end_lng,
                distance: (distance / 1000) |> Decimal.from_float() |> Decimal.round(0)
              }
            ]
      end)

    {:ok, %{tasks: tasks}}
  end
end
