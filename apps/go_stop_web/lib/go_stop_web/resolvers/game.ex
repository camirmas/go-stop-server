defmodule GoStopWeb.Resolvers.Game do
  alias Ecto.Multi
  alias GoStop.{Repo, Game, Player}
  import GoStopWeb.Errors

  def list_games(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, Game.list_for_user(current_user) |> Repo.preload(preloads())}
  end
  def list_games(_parent, _args, _resolution) do
    {:ok, Game.list(preload: preloads())}
  end

  def create_game(_parent,
    %{opponent_id: opponent_id},
    %{context: %{current_user: current_user}}) do
      multi =
        Multi.new()
        |> Multi.run(:game, fn _ ->
          Game.create(%{status: "pending"})
        end)
        |> Multi.run(:player_1, fn %{game: game} ->
          Player.create(%{
            status: "active",
            user_id: current_user.id,
            game_id: game.id,
            color: "black"
          })
        end)
        |> Multi.run(:player_2, fn %{game: game} ->
          Player.create(%{
            status: "user-pending",
            user_id: opponent_id,
            game_id: game.id,
            color: "white"
          })
        end)
        |> Multi.run(:updated_game, fn %{game: game, player_1: player_1} ->
          game = Repo.preload(game, preloads())
          Game.update(game, %{player_turn_id: player_1.id})
        end)

      case Repo.transaction(multi) do
        {:ok, %{updated_game: game}} ->
          {:ok, game}
        {:error, _transaction_name, changeset, _} ->
          changeset_errors(changeset)
      end
  end

  def create_game(_, _, _) do
    authentication_error()
  end

  def get_game(_parent, %{id: id}, _resolution) do
    {:ok, GoStop.Game.get(id, preload: preloads())}
  end

  defp preloads do
    [:stones, players: [:user]]
  end
end
