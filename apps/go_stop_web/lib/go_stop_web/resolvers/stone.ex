defmodule GoStopWeb.Resolvers.Stone do
  alias Ecto.Multi

  alias GoStop.{Repo, Stone}

  def add_stone(_parent,
    %{game_id: game_id} = data, %{context: %{current_user: current_user}}) do
      result =
        Repo.transaction(fn ->
          case GoStop.Stone.create(data) do
            {:ok, stone} ->
              if player_turn?(game_id, current_user) do
                stone
              else
                Repo.rollback(:wrong_turn)
              end
            {:error, changeset} -> Repo.rollback("Failed: #{parse_errors(changeset)}")
          end
        end)

      case result do
        {:ok, stone} = stone -> stone
        {:error, :wrong_turn} ->
          {:error, "Failed: wrong player turn"}
        err -> err
      end
  end

  def add_stone(_, _, _) do
    {:error, "Failed: user not authenticated"}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end

  defp player_turn?(game_id, current_user) do
    case GoStop.Game.get(game_id, preload: [:players]) do
      nil -> false
      game ->
        player = Enum.find(game.players, fn p -> p.user_id == current_user.id end)
        player && player.id == game.player_turn_id
    end
  end
end
