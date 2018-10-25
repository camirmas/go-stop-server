defmodule GameLogicTest do
  use ExUnit.Case

  def build_board(stones, fill) do
    0..18 |> Enum.map(fn x ->
      0..18 |> Enum.map(fn y ->
        color =
          if fill do
            Enum.random(["black", "white", ""])
          else
            ""
          end
        existing =
          Enum.find(stones, fn {sx, sy, _} ->
            sx == x && sy == y
          end)

        case existing do
          {_x, _y, c} -> c
          _ -> color
        end
      end)
    end)
  end

  test "#run" do
    stones = build_board([{1, 0, "white"}], true)
    assert (Enum.at(stones, 1) |> Enum.at(0)) == "white"
  end

  test "#run basic" do
    stones = build_board([
      {0, 1, "black"},
      {1, 1, "white"},
      {1, 0, "black"},
      {2, 0, "black"},
      {1, 2, "black"},
    ], false)

    assert GameLogic.run(stones, {0, 1, "black"}) == {1, 1, "white"}
  end

  test "#is_edge" do
    assert GameLogic.is_edge({1, 0, ""})
    assert GameLogic.is_edge({1, 18, ""})
    assert GameLogic.is_edge({0, 1, ""})
    assert GameLogic.is_edge({18, 1, ""})
    refute GameLogic.is_edge({3, 6, ""})
  end

  test "#find_nearby" do
    stones = build_board([
      {0, 1, ""},
      {1, 1, "white"},
      {1, 0, "black"},
    ], true)

    assert GameLogic.find_nearby(stones, {0, 0, "black"}) == [{0, 1}, {1, 0}]
  end
end
