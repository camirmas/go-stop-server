defmodule GoStopWeb.Resolvers.Stone do
  alias Ecto.Multi

  alias GoStop.{Repo, Player, Game, Stone}
  import GoStopWeb.Errors

  def add_stone(_parent,
    %{game_id: game_id} = data, %{context: %{current_user: current_user}}) do
      player = Player.get_by(%{game_id: game_id, user_id: current_user.id})

      if player do
        player = player |> Repo.preload(:game)

        if Player.is_turn?(player) do
          create_stone(data, player)
        else
          wrong_turn_error()
        end
      else
        game_not_found_error()
      end
  end

  def add_stone(_, _, _) do
    authentication_error()
  end

  defp create_stone(data, %{game: game} = player) do
    multi =
      Multi.new
      |> Multi.run(:stone, fn _ ->
        params = Map.put(data, :color, player.color)
        Stone.create(params)
      end)
      |> Multi.run(:game, fn _ ->
        opponent = Player.get_opponent(player)
        Game.update(game, %{player_turn_id: opponent.id})
      end)

    case Repo.transaction(multi) do
      {:ok, %{stone: stone}} -> {:ok, stone}
      {:error, _name, changeset, _} ->
        changeset_errors(changeset)
    end
  end
end
