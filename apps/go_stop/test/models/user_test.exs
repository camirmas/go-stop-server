defmodule UserTest do
  use GoStop.DataCase

  @params %{
    username: "Obi-Wan",
    email: "obi-wan@jedicouncil.org",
    password: "ihavethehighground"
  }

  def is_valid(changeset) do
    %Ecto.Changeset{valid?: valid} = changeset

    valid
  end

  describe "changesets" do
    test "changeset is valid with username, email, password" do
      changeset = GoStop.User.registration_changeset(%GoStop.User{}, @params)

      assert is_valid(changeset)
    end

    test "changeset is invalid with improper email format" do
      params = %{@params | email: "wrong"}
      changeset = GoStop.User.registration_changeset(%GoStop.User{}, params)

      assert not is_valid(changeset)
    end

    test "changeset is invalid with improper password length" do
      params = %{@params | password: "short"}
      changeset = GoStop.User.registration_changeset(%GoStop.User{}, params)

      assert not is_valid(changeset)
    end
  end

  describe "model" do
    test "cannot create a user with existing username" do
      GoStop.User.registration_changeset(%GoStop.User{}, @params) |> GoStop.Repo.insert!
      {:error, _changeset} =
        GoStop.User.registration_changeset(%GoStop.User{}, @params)
        |> GoStop.Repo.insert
    end

    test "cannot create a user with existing email" do
      GoStop.User.registration_changeset(%GoStop.User{}, @params) |> GoStop.Repo.insert!
      params = %{@params | username: "dude"}
      {:error, _changeset} =
        GoStop.User.registration_changeset(%GoStop.User{}, params)
        |> GoStop.Repo.insert
    end
  end
end
