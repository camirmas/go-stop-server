defmodule GoStopWeb.Resolvers.Game do
  def get_game(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Game.get(id, preload: preloads())}
  end

  def list_games(_parent, _args, _resolution) do
    {:ok, GoStop.Game.list(preload: preloads())}
  end

  defp preloads do
    [players: [:user]]
  end
end
