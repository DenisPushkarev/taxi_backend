defmodule Taxi.Task do
  import Ecto.Query
  alias Taxi.Db.Tasks
  alias Taxi.Repo

  def add(task = %{start_lat: _, start_lng: _, end_lat: _, end_lng: _}) do
    task = %Tasks{task | uuid: UUID.uuid4(), status: "new"}

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
    r = query |> Repo.all()
    {:ok, %{tasks: r, total: total}}
  end

  defp count(query) do
    query |> select([:uuid]) |> Repo.aggregate(:count, :uuid)
  end
end
