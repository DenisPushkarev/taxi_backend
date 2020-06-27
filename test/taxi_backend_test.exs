defmodule TaxiBackendTest do
  use ExUnit.Case
  doctest TaxiBackend

  test "greets the world" do
    assert TaxiBackend.hello() == :world
  end
end
