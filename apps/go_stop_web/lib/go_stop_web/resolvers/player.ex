defmodule GoStopWeb.Resolvers.Player do
  def create_player(_parent, data, _resolution) do
    case GoStop.Player.create(data) do
      {:ok, _} = player -> player
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  def get_player(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Player.get(id, preload: [:user, :game])}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end
end
