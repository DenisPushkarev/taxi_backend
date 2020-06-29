defmodule Taxi.Task do
  import Ecto.Query
  import Geo.PostGIS
  alias Taxi.Db.Tasks
  alias Taxi.Repo

  def add(%{start_point: {slt, slg}, end_point: {elt, elg}, note: note})
      when is_float(slt) and is_float(slg) and is_float(elt) and is_float(elg) do
    geom_start = %Geo.Point{coordinates: {slt, slg}, srid: 4326}
    geom_end = %Geo.Point{coordinates: {slt, slg}, srid: 4326}

    task = %Tasks{
      start_point: geom_start,
      end_point: geom_end,
      uuid: UUID.uuid4(),
      note: note,
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
        t |> task_to_map()

      _ ->
        :not_found
    end
  end

  def list(_opts) do
    query = from(t in Tasks, where: fragment("? != ?", t.status, "deleted"))
    total = query |> count()
    tasks = query |> Repo.all()
    {:ok, %{tasks: task_to_map(tasks), total: total}}
  end

  defp count(query) do
    query |> select([:uuid]) |> Repo.aggregate(:count, :uuid)
  end

  def assign_driver(driver_id, task_id) when is_binary(driver_id) and is_binary(task_id) do
    case Repo.get_by(Tasks, driver: driver_id, status: "processing") do
      nil ->
        result =
          from(task in Tasks, where: task.uuid == ^task_id and task.status == "new")
          |> Repo.update_all(set: [driver: driver_id, status: "processing"])

        case result do
          {1, nil} -> :ok
          {0, nil} -> {:error, :already_taken}
          _ -> :error
        end

      _ ->
        {:error, :driver_has_processing}
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

  def find_nearest(lat, lng, opts \\ %{}) when is_float(lat) and is_float(lng) do
    geom = %Geo.Point{coordinates: {lat, lng}, srid: 4326}
    limit = min(100, Map.get(opts, :limit, 20))

    query =
      from(task in Tasks,
        limit: ^limit,
        where: task.status == "new",
        order_by: st_distance(task.start_point, ^geom)
      )

    tasks =
      query
      |> Repo.all()
      |> task_to_map()
      |> Enum.map(
        &Map.put(
          &1,
          :distance,
          (Geocalc.distance_between([&1.start_lat, &1.start_lng], [lat, lng]) / 1000)
          |> Decimal.from_float()
          |> Decimal.round(0)
        )
      )

    {:ok, %{tasks: tasks}}
  end

  defp task_to_map(t = %Taxi.Db.Tasks{}) when is_map(t) do
    %{
      task_id: t.uuid,
      start_lat: t.start_point.coordinates |> elem(0),
      start_lng: t.start_point.coordinates |> elem(1),
      end_lat: t.end_point.coordinates |> elem(0),
      end_lng: t.start_point.coordinates |> elem(1),
      driver: t.driver,
      status: t.status,
      note: t.note
    }
  end

  defp task_to_map(tasks) when is_list(tasks) do
    Enum.map(tasks, &task_to_map(&1))
  end
end
