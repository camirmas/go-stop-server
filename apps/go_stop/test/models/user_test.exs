defmodule UserTest do
  use GoStop.DataCase, async: true

  import Ecto.Changeset, only: [get_change: 2]
  alias GoStop.User

  @params %{
    username: "Obi-Wan",
    email: "obi-wan@jedicouncil.org",
    password: "ihavethehighground"
  }

  describe "changesets" do
    test "is valid with username, email, password" do
      changeset = User.registration_changeset(%User{}, @params)

      assert is_valid(changeset)
    end

    test "downcases emails" do
      params = %{@params | email: String.upcase(@params.email)}
      changeset = User.registration_changeset(%User{}, params)

      assert get_change(changeset, :email) == @params.email
    end

    test "is invalid with improper email format" do
      invalid_emails = ~w(user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com)
      Enum.each(invalid_emails, fn email ->
        params = %{@params | email: email}
        changeset = User.registration_changeset(%User{}, params)

        assert not is_valid(changeset)
      end)
    end

    test "is invalid with improper password length" do
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

    test "with the wrong username returns `nil`" do
      assert is_nil User.get_by(%{username: "dude"})
    end

    test "with the wrong id returns `nil`" do
      assert is_nil User.get_by(%{id: "123"})
    end
  end
end
