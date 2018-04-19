defmodule GameLogicTest do
  use ExUnit.Case
  doctest GameLogic

  test "greets the world" do
    assert GameLogic.hello() == :world
  end
end
