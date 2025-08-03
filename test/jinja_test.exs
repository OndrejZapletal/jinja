defmodule JinjaTest do
  use ExUnit.Case
  doctest Jinja

  test "greets the world" do
    assert Jinja.hello() == :world
  end
end
