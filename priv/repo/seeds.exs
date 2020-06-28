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
