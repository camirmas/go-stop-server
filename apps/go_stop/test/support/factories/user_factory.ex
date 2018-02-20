defmodule GoStop.Factories.User do
  use ExMachina.Ecto, repo: GoStop.Repo

  def create_user(params \\ %{}) do
    %GoStop.User{}
    |> GoStop.User.registration_changeset(build(:user, params))
    |> GoStop.Repo.insert!
  end

  def user_factory do
    %{
      username: sequence(:username, fn(i) -> "email-#{i}@example.com" end),
      email: sequence(:email, fn(i) -> "email-#{i}@example.com" end),
      password: "password"
    }
  end
end
