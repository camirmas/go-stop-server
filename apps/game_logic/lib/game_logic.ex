defmodule GameLogic do
  defmodule Board do
    defstruct size: 13, stones: []
  end

  defmodule Stone do
    defstruct x: 0, y: 0, color: nil
  end

  def run(%Board{stones: stones} = board) do
    board
    |> get_chains
    |> Enum.map(fn chain -> find_liberties(board, chain) end)
    |> Enum.filter(fn {chain, liberties} -> liberties == 0 end)
    |> Enum.map(fn {chain, liberties} -> chain end)
  end

  def get_chains(%Board{stones: stones} = board) do
    stones
    |> Enum.map(fn stone ->
      board
      |> get_chain(stone)
      |> Enum.sort_by(fn %{x: x, y: y} -> {x, y} end)
    end)
    |> Enum.dedup()
  end

  def find_liberties(board, chain) do
    liberties = chain
      |> Enum.reduce([], fn(stone, total_acc) ->
        individual_liberties = board
          |> get_nearby_liberties(stone)
          |> Enum.reduce([], fn (%{color: color} = stone, acc_i) ->
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

    {chain, length(liberties)}
  end

  defp get_chain(board, %Stone{} = stone) do
    get_chain_helper(board, [stone], [], stone.color)
  end

  defp get_chain_helper(_, [], chain, color), do: chain

  defp get_chain_helper(board, acc, chain, color) do
    [s | acc] = acc

    if s not in chain && s.color == color do
      chain = [s | chain]

      acc =
        board
        |> get_nearby_stones(s)
        |> Enum.concat(acc)

      get_chain_helper(board, acc, chain, color)
    else
      get_chain_helper(board, acc, chain, color)
    end
  end

  defp get_nearby_stones(%Board{stones: stones, size: size}, s) do
    up = %Stone{x: s.x, y: s.y + 1}
    down = %Stone{x: s.x, y: s.y - 1}
    left = %Stone{x: s.x - 1, y: s.y}
    right = %Stone{x: s.x + 1, y: s.y}
    top_left = %Stone{x: s.x - 1, y: s.y + 1}
    top_right = %Stone{x: s.x + 1, y: s.y + 1}
    bottom_left = %Stone{x: s.x - 1, y: s.y - 1}
    bottom_right = %Stone{x: s.x + 1, y: s.y - 1}

    [up, down, left, right, top_left, top_right, bottom_left, bottom_right]
    |> Enum.filter(fn stone -> is_inbounds(stone, size) end)
    |> Enum.map(fn nearby ->
      stone = Enum.find(stones, fn stone ->
        {stone.x, stone.y} == {nearby.x, nearby.y}
      end)

      if stone do
        %{nearby | color: stone.color}
      else
        nearby
      end
    end)
  end

  def get_nearby_liberties(%Board{stones: stones, size: size}, s) do
    up = %Stone{x: s.x, y: s.y + 1}
    down = %Stone{x: s.x, y: s.y - 1}
    left = %Stone{x: s.x - 1, y: s.y}
    right = %Stone{x: s.x + 1, y: s.y}

    [up, down, left, right]
      |> Enum.filter(fn stone -> is_inbounds(stone, size) end)
      |> Enum.map(fn nearby ->
        stone = Enum.find(stones, fn stone ->
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
