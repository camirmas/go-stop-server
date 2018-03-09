defmodule GoStopWeb.Resolvers.Player do
  def get_player(_, %{id: id}, _) do
    {:ok, GoStop.Player.get(id)}
  end
end
