defmodule GoStop.Factory do
  use ExMachina.Ecto, repo: GoStop.Repo

  alias GoStop.{User, Player, Game}

  def user_factory do
    %User{
      username: sequence(:username, fn(i) -> "email-#{i}@example.com" end),
      email: sequence(:email, fn(i) -> "email-#{i}@example.com" end),
      encrypted_password: "123abc"
    }
  end

  def game_factory do
    [status] = Enum.take_random(~w(pending active complete), 1)
    %GoStop.Game{
      status: status
    }
  end

  def player_factory do
    [status] = ~w(user-pending active) |> Enum.take_random(1)
    %Player{
      status: status,
      user: build(:user),
      game: build(:game)
    }
  end
end
