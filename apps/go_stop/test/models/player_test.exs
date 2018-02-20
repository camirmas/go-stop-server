defmodule PlayerTest do
  use GoStop.DataCase

  alias GoStop.Factories

  @params %{
    user_id: 1,
    game_id: 1,
    status: "active"
  }

  describe "changesets" do
    test "changeset is valid with user_id, game_id, status" do
      changeset = GoStop.Player.changeset(%GoStop.Player{}, @params)

      assert is_valid(changeset)
    end

    test "changeset is invalid with missing status" do
      changeset = GoStop.Player.changeset(
        %GoStop.Player{}, Map.drop(@params, [:status])
      )
      refute is_valid(changeset)
    end

    test "changeset is invalid with improper status" do
      changeset = GoStop.Player.changeset(
        %GoStop.Player{}, %{ @params | status: "super" }
      )
      refute is_valid(changeset)
    end
  end

  describe "model" do
    test "cannot create a player with invalid user_id" do
      %{id: game_id} = Factories.Game.insert(:game)

      changeset = GoStop.Player.changeset(
        %GoStop.Player{}, %{ @params | game_id: game_id }
      )
      {:error, _changeset} =
        changeset |> GoStop.Repo.insert()
    end

    test "cannot create a player with invalid game_id" do
      %{id: user_id} = Factories.User.create_user()

      changeset = GoStop.Player.changeset(
        %GoStop.Player{}, %{ @params | user_id: user_id }
      )
      {:error, _changeset} =
        changeset |> GoStop.Repo.insert()
    end
  end
end
