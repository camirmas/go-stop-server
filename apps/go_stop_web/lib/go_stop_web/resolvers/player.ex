defmodule GoStopWeb.Resolvers.Player do
  alias Ecto.Multi

  alias GoStop.{Repo, Player, Game}
  import GoStopWeb.Errors

  def get_player(_parent, %{id: id}, _resolution) do
    {:ok, Player.get(id, preload: [:user, :game])}
  end

  def pass(_parent, %{game_id: game_id},
           %{context: %{current_user: current_user}}) do
    player = Player.get_by(%{game_id: game_id, user_id: current_user.id})

    if player do
      player = player |> Repo.preload(:game)

      if Player.is_turn?(player) do
        update_player(player)
      else
        wrong_turn_error()
      end
    else
      game_not_found_error()
    end
  end

  def pass(_, _, _) do
    authentication_error()
  end

  defp update_player(%{game: game} = player) do
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
          new_player = Player.get_opponent(player)
          Game.update(game, %{player_turn_id: new_player.id})
        end
      end)

    case Repo.transaction(multi) do
      {:ok, %{player: player}} -> {:ok, player}
      {:error, _name, changeset, _} ->
        changeset_errors(changeset)
    end
  end
end
