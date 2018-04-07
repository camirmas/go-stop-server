defmodule GoStopWeb.Resolvers.Stone do
  alias Ecto.{Multi, Changeset}

  alias GoStop.{Repo, Game, Stone}

  def add_stone(_parent,
    %{game_id: game_id} = data, %{context: %{current_user: current_user}}) do
      multi =
        Multi.new
        |> Multi.run(:stone, fn _ ->
          case GoStop.Stone.create(data) do
            {:ok, stone} ->
              # TODO: refactor this section to be extensible for game rules
              if player_turn?(game_id, current_user) do
                {:ok, stone |> Repo.preload(:game)}
              else
                changeset =
                  stone
                  |> Stone.changeset(%{})
                  |> Changeset.add_error(:player, "must wait a turn")
                {:error, changeset}
              end
            err -> err
          end
        end)
        |> Multi.run(:game, fn %{stone: stone} ->
          game = stone.game |> Repo.preload(:players)
          {game, new_player} = get_new_player(game, current_user)
          Game.update(game, %{player_turn_id: new_player.id})
        end)

      case Repo.transaction(multi) do
        {:ok, %{stone: stone}} -> {:ok, stone}
        {:error, _name, changeset, _} ->
          {:error, "Failed: #{parse_errors(changeset)}"}
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
    case Game.get(game_id, preload: [:players]) do
      nil -> false
      game ->
        player = Enum.find(game.players, fn p -> p.user_id == current_user.id end)
        player && player.id == game.player_turn_id
    end
  end

  defp get_new_player(game, current_user) do
    player = Enum.find(game.players, fn p -> p.user_id != current_user.id end)
    {game, player}
  end
end
