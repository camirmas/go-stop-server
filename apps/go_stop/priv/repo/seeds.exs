# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GoStop.Repo.insert!(%GoStop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule GoStop.Seeds do
  def seed do
    1..5
    |> Enum.map(fn _ ->
      game = create_game()
      create_player(%{game_id: game.id, color: "black"})
      create_player(%{game_id: game.id, color: "white"})
    end)
  end

  defp create_user do
    {:ok, user} = GoStop.User.create(%{
      username: FakerElixir.Helper.unique!(:usernames, fn -> "#{FakerElixir.Internet.user_name}#{rand_number()}" end),
      email: FakerElixir.Helper.unique!(:emails, fn -> "#{rand_number()}-#{FakerElixir.Internet.email}" end),
      password: FakerElixir.Internet.password(:strong)
    })

    # credo:disable-for-next-line
    IO.inspect "Created User-- #{user.username}/#{user.id}"

    user
  end

  defp create_game do
    [status] = Enum.take_random(~w(pending active complete), 1)
    {:ok, game} = GoStop.Game.create(%{status: status})

    IO.inspect "Created Game-- #{game.id}"

    game
  end

  def create_player(%{game_id: game_id, color: color}) do
    [status] = Enum.take_random(~w(user-pending active), 1)
    {:ok, player} =
      %{
        status: status,
        user_id: create_user().id,
        game_id: game_id,
        color: color
      }
      |> GoStop.Player.create

    IO.inspect "Created Player -- #{player.id}"
  end

  defp rand_number, do: :rand.uniform(1000)
end

GoStop.Seeds.seed()
