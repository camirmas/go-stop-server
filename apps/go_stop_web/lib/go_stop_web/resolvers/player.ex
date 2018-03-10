defmodule GoStopWeb.Resolvers.Player do
  def get_player(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Player.get(id)}
  end
end
