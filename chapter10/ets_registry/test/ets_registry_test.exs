defmodule EtsRegistryTest do
  use ExUnit.Case
  doctest EtsRegistry

  test "greets the world" do
    assert EtsRegistry.hello() == :world
  end
end
