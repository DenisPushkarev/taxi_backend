defmodule Taxi.Web.Auth.Authorization do
  alias Taxi.Web.Auth.Token, as: TaxiToken

  def authorize(login = "driver", "driver") do
    {:ok, makeToken(login, :driver)}
  end

  def authorize(login = "manager", "manager") do
    {:ok, makeToken(login, :manager)}
  end

  def authorize(_, _), do: :invalid_login

  def makeToken(login, role) do
    extra_claims = %{"user_id" => login, "role" => role}
    TaxiToken.generate_and_sign!(extra_claims)
  end
end
