defmodule GoStopWeb.Resolvers.Stone do
  alias Ecto.Multi

  alias GoStop.{Repo, Player, Game, Stone}
  import GoStopWeb.Errors

  def add_stone(_parent,
    %{game_id: game_id} = data, %{context: %{current_user: current_user}}) do
      player = Player.get_by(%{game_id: game_id, user_id: current_user.id})

      create_stone(data, player)
  end

  def add_stone(_, _, _) do
    authentication_error()
  end

  defp create_stone(_, nil) do
    game_not_found_error()
  end
  defp create_stone(data, player) do
    player
    |> Repo.preload([:game])
    |> validate_turn()
    |> build_turn(data)
    |> execute_turn()
  end

  defp build_turn(%{game: game} = player, data) do
    Multi.new
    |> Multi.run(:stone, fn _ ->
      params = Map.put(data, :color, player.color)
      Stone.create(params)
    end)
    |> Multi.run(:game, fn _ ->
      opponent = Player.get_opponent(player)
      Game.update(game, %{player_turn_id: opponent.id})
    end)
  end
  defp build_turn(false, _) do
    wrong_turn_error()
  end

  defp execute_turn({:error, _} = err), do: err
  defp execute_turn(multi) do
    case Repo.transaction(multi) do
      {:ok, %{stone: stone}} -> {:ok, stone}
      {:error, _name, changeset, _} ->
        changeset_errors(changeset)
    end
  end

  defp validate_turn(player) do
    Player.is_turn?(player) && player
  end
end
