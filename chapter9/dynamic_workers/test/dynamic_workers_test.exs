defmodule DynamicWorkersTest do
  use ExUnit.Case
  doctest DynamicWorkers

  test "greets the world" do
    assert DynamicWorkers.hello() == :world
  end
end
