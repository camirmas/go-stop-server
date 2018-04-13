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

    pass_turn(player)
  end

  def pass(_, _, _) do
    authentication_error()
  end

  defp pass_turn(nil) do
    game_not_found_error()
  end
  defp pass_turn(player) do
    player
    |> Repo.preload([:game])
    |> validate_turn()
    |> build_turn()
    |> execute_turn()
  end

  defp validate_turn(player) do
    if Player.is_turn?(player) do
      player
    else
      wrong_turn_error()
    end
  end

  defp build_turn(%{game: game} = player) do
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
  end
  defp build_turn({:error, _} = err), do: err

  defp execute_turn({:error, _} = err), do: err
  defp execute_turn(multi) do
    case Repo.transaction(multi) do
      {:ok, %{player: player}} -> {:ok, player}
      {:error, _name, changeset, _} ->
        changeset_errors(changeset)
    end
  end
end
