defmodule GameLogic do
  defmodule Board do
    defstruct size: 13, stones: []
  end

  defmodule Stone do
    defstruct x: 0, y: 0, color: nil
  end

  def run(%Board{} = board, %Stone{} = added_stone) do
    board
    |> get_strings
    # TODO: modify to prevent suicidal moves (see issue #25)
    |> Enum.filter(fn string -> added_stone not in string end)
    |> Enum.map(fn string -> find_liberties(board, string) end)
    |> Enum.filter(fn {_string, liberties} -> liberties == 0 end)
    |> Enum.map(fn {string, _liberties} -> string end)
  end

  def get_strings(%Board{stones: stones} = board) do
    stones
    |> Enum.map(fn stone ->
      board
      |> get_string(stone)
      |> Enum.sort_by(fn %{x: x, y: y} -> {x, y} end)
    end)
    |> Enum.dedup()
  end

  def find_liberties(board, string) do
    liberties =
      string
      |> Enum.reduce([], fn stone, total_acc ->
        individual_liberties =
          board
          |> get_nearby(stone)
          |> Enum.reduce([], fn %{color: color} = stone, acc_i ->
            if is_nil(color) do
              [stone | acc_i]
            else
              acc_i
            end
          end)

        total_acc ++ individual_liberties
      end)
      |> List.flatten()
      |> Enum.dedup()

    {string, length(liberties)}
  end

  defp get_string(board, %Stone{} = stone) do
    get_string_helper(board, [stone], [], stone.color)
  end

  defp get_string_helper(_board, [], string, _color), do: string

  defp get_string_helper(board, acc, string, color) do
    [s | acc] = acc

    if s not in string && s.color == color do
      string = [s | string]

      acc =
        board
        |> get_nearby(s)
        |> Enum.concat(acc)

      get_string_helper(board, acc, string, color)
    else
      get_string_helper(board, acc, string, color)
    end
  end

  defp get_nearby(%Board{stones: stones, size: size}, s) do
    up = %Stone{x: s.x, y: s.y + 1}
    down = %Stone{x: s.x, y: s.y - 1}
    left = %Stone{x: s.x - 1, y: s.y}
    right = %Stone{x: s.x + 1, y: s.y}

    [up, down, left, right]
    |> Enum.filter(fn stone -> is_inbounds(stone, size) end)
    |> Enum.map(fn nearby ->
      stone =
        Enum.find(stones, fn stone ->
          {stone.x, stone.y} == {nearby.x, nearby.y}
        end)

      if stone do
        %{nearby | color: stone.color}
      else
        nearby
      end
    end)
  end

  defp is_inbounds(%Stone{x: x, y: y}, size) do
    cond do
      x < 0 ->
        false

      x >= size ->
        false

      y < 0 ->
        false

      y >= size ->
        false

      true ->
        true
    end
  end
end
