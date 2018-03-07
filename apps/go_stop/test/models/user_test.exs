defmodule UserTest do
  use GoStop.DataCase

  alias GoStop.User

  @params %{
    username: "Obi-Wan",
    email: "obi-wan@jedicouncil.org",
    password: "ihavethehighground"
  }

  describe "changesets" do
    test "changeset is valid with username, email, password" do
      changeset = User.registration_changeset(%User{}, @params)

      assert is_valid(changeset)
    end

    test "changeset is invalid with improper email format" do
      params = %{@params | email: "wrong"}
      changeset = User.registration_changeset(%User{}, params)

      assert not is_valid(changeset)
    end

    test "changeset is invalid with improper password length" do
      params = %{@params | password: "short"}
      changeset = User.registration_changeset(%User{}, params)

      assert not is_valid(changeset)
    end
  end

  test "#list" do
    {:ok, user} = User.create(@params)

    assert [user] == User.list
  end

  describe "#create" do
    test "cannot create a user with existing username" do
      User.create(@params)

      assert {:error, _changeset} = User.create(@params)
    end

    test "cannot create a user with existing email" do
      User.create(@params)

      params = %{@params | username: "dude"}
      assert {:error, _changeset} = User.create(params)
    end
  end

  describe "#get_by" do
    setup do
      {:ok, user} = User.create(@params)

      [user: user]
    end

    test "can get a User by `username`", %{user: user} do
      res = User.get_by(%{username: user.username})

      assert res == user
    end

    test "can get a User by id", %{user: user} do
      res = User.get_by(%{id: user.id})

      assert res == user
    end
  end
end
