defmodule GameLogic do
  @moduledoc """
  Documentation for GameLogic.
  """

  @doc """
  Runs the game rules, given an existing board and a new stone.
  """
  def run(stones, stone) do
    stones
    |> find_polygon(stone, [])
    # |> determine_captures()
  end

  def find_polygon([], _, group), do: group
  def find_polygon(stones, stone, group) do
    nearby = find_nearby(stones, stone)
    find_polygon(nearby, stone, group ++ nearby)
  end

  @doc """
  Finds nearby (1 unit) stones that are of the same color, or are edges.
  """
  def find_nearby(stones, {x, y, color}) do
    up =
      if y + 1 <= 18 && validate_stone(stones, {x, y + 1, color}) do
        {x, y + 1}
      end
    down =
      if y - 1 >= 0 && validate_stone(stones, {x, y - 1, color}) do
        {x, y - 1}
      end
    left =
      if x - 1 >= 0 && validate_stone(stones, {x - 1, y, color}) do
        {x - 1, y}
      end
    right =
      if x + 1 <= 18 && validate_stone(stones, {x + 1, y, color}) do
        {x + 1, y}
      end

    [up, down, left, right] |> Enum.filter(&is_tuple/1)
  end

  def is_edge({x, y, _} = stone) do
    case x do
      0 -> true
      18 -> true
      _ -> y == 0 || y == 18
    end
  end

  def validate_stone(stones, stone) do
    has_stone(stones, stone) || is_edge(stone)
  end

  def has_stone(stones, {x, y, color}) do
    stone = stones |> Enum.at(x) |> Enum.at(y)
    stone == color
  end
end
