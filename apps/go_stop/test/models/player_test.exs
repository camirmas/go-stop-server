defmodule PlayerTest do
  use GoStop.DataCase

  alias GoStop.{Repo, Player}

  @params %{
    user_id: 1,
    game_id: 1,
    status: "active"
  }

  describe "changesets" do
    test "changeset is valid with user_id, game_id, status" do
      changeset = Player.changeset(%Player{}, @params)

      assert is_valid(changeset)
    end

    test "changeset is invalid with missing status" do
      changeset = Player.changeset(
        %Player{}, Map.drop(@params, [:status])
      )
      refute is_valid(changeset)
    end

    test "changeset is invalid with improper status" do
      changeset = Player.changeset(
        %Player{}, %{ @params | status: "super" }
      )
      refute is_valid(changeset)
    end
  end

  describe "#create" do
    test "cannot create a player with invalid user_id" do
      %{id: game_id} = insert(:game)

      changeset = Player.changeset(
        %Player{}, %{ @params | game_id: game_id }
      )
      {:error, _changeset} =
        changeset |> Repo.insert()
    end

    test "cannot create a player with invalid game_id" do
      %{id: user_id} = insert(:user)

      changeset = Player.changeset(
        %Player{}, %{ @params | user_id: user_id }
      )
      {:error, _changeset} =
        changeset |> Repo.insert()
    end
  end

  describe "#get" do
    test "with valid id returns a `Player`" do
      player = insert(:player)
      assert Player.get(player.id)
    end

    test "with invalid id returns `nil`" do
      assert is_nil Player.get("123")
    end
  end
end
