defmodule Taxi.Web.Auth.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(default_exp: 7200)
  end
end
