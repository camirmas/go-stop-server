defmodule GoStopWeb.Resolvers.Game do
  def get_game(_, %{id: id}, _) do
    {:ok, GoStop.Game.get(id)}
  end
end
