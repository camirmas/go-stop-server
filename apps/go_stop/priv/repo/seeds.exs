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
    1..5 |> Enum.map(fn _ -> create_user() end)
    1..5 |> Enum.map(fn _ -> create_game() end)
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
  end

  defp rand_number, do: :rand.uniform(1000)
end

GoStop.Seeds.seed()
