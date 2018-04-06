defmodule GoStopWeb.Resolvers.Player do
  def get_player(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Player.get(id, preload: [:user, :game])}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end
end
