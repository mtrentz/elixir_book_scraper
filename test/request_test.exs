defmodule RequestTest do
  use ExUnit.Case
  doctest Request

  test "greets the world" do
    assert Request.hello() == :world
  end
end
