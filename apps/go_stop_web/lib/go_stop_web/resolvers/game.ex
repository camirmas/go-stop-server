defmodule GoStopWeb.Resolvers.Game do
  def list_games(_parent, _args, _resolution) do
    {:ok, GoStop.Game.list(preload: preloads())}
  end

  def create_game(_parent, data, %{context: %{current_user: current_user}}) do
    params = Map.put(data, :user_id, current_user.id)
    case GoStop.Game.create(params) do
      {:ok, _} = game -> game
      {:error, _transaction_name, changeset, _} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  def create_game(_parent, data, context) do
    {:error, "Failed: user not authenticated"}
  end

  def get_game(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Game.get(id, preload: preloads())}
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
