# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Checkers.Repo.insert!(%Taxi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Taxi.Repo.insert!(%Taxi.Db.Users{
  uuid: UUID.uuid4(),
  login: "driver",
  hashed_password: Taxi.Utils.hash_password("driver"),
  role: "driver"
})

Taxi.Repo.insert!(%Taxi.Db.Users{
  uuid: UUID.uuid4(),
  login: "driver1",
  hashed_password: Taxi.Utils.hash_password("driver1"),
  role: "driver"
})

Taxi.Repo.insert!(%Taxi.Db.Users{
  uuid: UUID.uuid4(),
  login: "driver2",
  hashed_password: Taxi.Utils.hash_password("driver2"),
  role: "driver"
})

Taxi.Repo.insert!(%Taxi.Db.Users{
  uuid: UUID.uuid4(),
  login: "manager",
  hashed_password: Taxi.Utils.hash_password("manager"),
  role: "manager"
})

Taxi.Repo.insert!(%Taxi.Db.Users{
  uuid: UUID.uuid4(),
  login: "manager1",
  hashed_password: Taxi.Utils.hash_password("manager1"),
  role: "manager"
})

Taxi.Repo.insert!(%Taxi.Db.Users{
  uuid: UUID.uuid4(),
  login: "manager2",
  hashed_password: Taxi.Utils.hash_password("manager2"),
  role: "manager"
})

Taxi.Repo.insert!(%Taxi.Db.Tasks{
  uuid: UUID.uuid4(),
  start_point: %Geo.Point{coordinates: {40.74266, -73.9892}, srid: 4326},
  end_point: %Geo.Point{coordinates: {40.75159, -73.99206}, srid: 4326},
  note: "10 Madison Sq W, New York, New York 10010 -> West 34th Street, New York, NY, USA"
})

Taxi.Repo.insert!(%Taxi.Db.Tasks{
  uuid: UUID.uuid4(),
  start_point: %Geo.Point{coordinates: {53.7236, 91.4617}, srid: 4326},
  end_point: %Geo.Point{coordinates: {53.72839, 91.4451}, srid: 4326},
  note: "Abakan, Russia"
})

Taxi.Repo.insert!(%Taxi.Db.Tasks{
  uuid: UUID.uuid4(),
  start_point: %Geo.Point{coordinates: {45.047130, 38.974260}, srid: 4326},
  end_point: %Geo.Point{coordinates: {45.047130, 38.974260}, srid: 4326},
  note: "Krasnodar, Russia"
})

Taxi.Repo.insert!(%Taxi.Db.Tasks{
  uuid: UUID.uuid4(),
  start_point: %Geo.Point{coordinates: {55.755825, 37.617298}, srid: 4326},
  end_point: %Geo.Point{coordinates: {52.720750, 37.326560}, srid: 4326},
  note: "Moscow, Russia"
})

Taxi.Repo.insert!(%Taxi.Db.Tasks{
  uuid: UUID.uuid4(),
  start_point: %Geo.Point{coordinates: {34.3925907, 132.4501172}, srid: 4326},
  end_point: %Geo.Point{coordinates: {34.3949491, 132.4363588}, srid: 4326},
  note: "Japain, Herosima"
})

Taxi.Repo.insert!(%Taxi.Db.Tasks{
  uuid: UUID.uuid4(),
  start_point: %Geo.Point{coordinates: {82.50792, -62.5571846}, srid: 4326},
  end_point: %Geo.Point{coordinates: {82.4743657, -62.4949625}, srid: 4326},
  note: "Alert, Canada"
})
