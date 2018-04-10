defmodule GoStopWeb.Resolvers.Player do
  alias Ecto.Multi

  alias GoStop.{Repo, Player, Game}

  def get_player(_parent, %{id: id}, _resolution) do
    {:ok, Player.get(id, preload: [:user, :game])}
  end

  def player_pass(_parent, %{game_id: game_id},
                  %{context: %{current_user: current_user}}) do
    game = get_game(game_id)

    changeset = Player.changeset(%Player{}, %{})

    if game do
      player = get_player(game, current_user)

      if player do
        player = player |> Repo.preload(:game)

        if player_turn?(player) do
          update_player(game, player)
        else
          {:error, "Failed: player must wait a turn"}
        end
      else
        {:error, "Failed: player does not exist"}
      end
    else
      {:error, "Failed: game does not exist"}
    end
  end

  def player_pass(_, _, _) do
    {:error, "Failed: user not authenticated"}
  end

  defp update_player(game, player) do
    multi =
      Multi.new
      |> Multi.run(:player, fn _ ->
        Player.update(player, %{has_passed: true})
      end)
      |> Multi.run(:game, fn %{player: player} ->
        players = Player.list_for_game(game)

        if Enum.all?(players, &(&1.has_passed)) do
          # TODO: run score calculation
          Game.update(game, %{status: "complete"})
        else
          new_player = get_new_player(game, player)
          Game.update(game, %{player_turn_id: new_player.id})
        end
      end)

    case Repo.transaction(multi) do
      {:ok, %{player: player}} -> {:ok, player}
      {:error, _name, changeset, _} ->
        {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  defp get_game(game_id) do
    Game.get(game_id, preload: [:players])
  end

  defp get_player(game, current_user) do
    Enum.find(game.players, fn p -> p.user_id == current_user.id end)
  end

  defp player_turn?(player) do
    player && player.id == player.game.player_turn_id
  end

  defp get_new_player(game, player) do
    Enum.find(game.players, fn p -> p.id != player.id end)
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end
end
