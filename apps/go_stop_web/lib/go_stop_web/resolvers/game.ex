defmodule GoStopWeb.Resolvers.Game do
  def get_game(_, %{id: id}, _) do
    {:ok, GoStop.Game.get(id)}
  end

  def list_games(_, _, _) do
    {:ok, GoStop.Game.list()}
  end
end
