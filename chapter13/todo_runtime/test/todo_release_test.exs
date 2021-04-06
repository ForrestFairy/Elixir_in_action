defmodule TodoReleaseTest do
  use ExUnit.Case
  doctest TodoRelease

  test "greets the world" do
    assert TodoRelease.hello() == :world
  end
end
