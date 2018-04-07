defmodule GoStopWeb.Resolvers.Stone do
  alias Ecto.{Multi, Changeset}

  alias GoStop.{Repo, Game, Stone}

  def add_stone(_parent,
    %{game_id: game_id} = data, %{context: %{current_user: current_user}}) do
      game = get_game(game_id)

      changeset = Stone.changeset(%Stone{}, %{})

      if game do
        player = get_player(game, current_user)

        if player do
          player = player |> Repo.preload(:game)

          if player_turn?(player) do
            create_stone(data, player)
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

  def add_stone(_, _, _) do
    {:error, "Failed: user not authenticated"}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
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
    player = Enum.find(game.players, fn p -> p.id != player.id end)
    {game, player}
  end


  defp create_stone(data, player) do
    multi =
      Multi.new
      |> Multi.run(:stone, fn _ ->
        params = Map.put(data, :color, player.color)
        Stone.create(params)
      end)
      |> Multi.run(:game, fn %{stone: stone} ->
        stone = stone |> Repo.preload(:game)
        game = stone.game |> Repo.preload(:players)
        {game, new_player} = get_new_player(game, player)
        Game.update(game, %{player_turn_id: new_player.id})
      end)

    case Repo.transaction(multi) do
      {:ok, %{stone: stone}} -> {:ok, stone}
      {:error, _name, changeset, _} ->
        {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end
end
