defmodule NikoTest do
  use ExUnit.Case
  doctest Niko

  test "greets the world" do
    assert Niko.hello() == :world
  end
end
