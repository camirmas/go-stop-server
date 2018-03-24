defmodule GoStopWeb.Resolvers.Game do
  def list_games(_parent, _args, _resolution) do
    {:ok, GoStop.Game.list(preload: preloads())}
  end

  def create_game(_parent, data, _resolution) do
    case GoStop.Game.create(data) do
      {:ok, _} = game -> game
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  def get_game(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Game.get(id, preload: preloads())}
  end

  def add_stone(_parent, data, _resolution) do
    case GoStop.Stone.create(data) do
      {:ok, _} = stone -> stone
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end

  defp preloads do
    [:stones, players: [:user]]
  end
end
