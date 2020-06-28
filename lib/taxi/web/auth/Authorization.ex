defmodule Taxi.Web.Auth.Authorization do
  alias Taxi.Web.Auth.Token, as: TaxiToken
  alias Taxi.Db.Users

  def authorize(login, password) do
    case Users |> Taxi.Repo.get_by(login: login) do
      %Users{uuid: uuid, role: role, login: ^login, hashed_password: hashed_password} ->
        if Taxi.Utils.validate_password(password, hashed_password) do
          {:ok, makeToken(uuid, role)}
        else
          :invalid_login
        end

      _ ->
        :invalid_login
    end
  end

  def makeToken(uuid, role) do
    extra_claims = %{"uuid" => uuid, "role" => role}
    TaxiToken.generate_and_sign!(extra_claims)
  end
end
