defmodule PlayerTest do
  use GoStop.DataCase, async: true

  alias GoStop.{Repo, Player}

  @params %{
    user_id: 1,
    game_id: 1,
    status: "active",
    color: "black"
  }

  describe "changesets" do
    test "changeset is valid with proper params" do
      changeset = Player.changeset(%Player{}, @params)

      assert is_valid(changeset)
    end

    test "changeset is invalid with missing color" do
      changeset = Player.changeset(%Player{}, Map.drop(@params, [:color]))

      refute is_valid(changeset)
    end

    test "changeset is invalid with improper color" do
      changeset = Player.changeset(%Player{}, %{@params | color: "wrong"})

      refute is_valid(changeset)
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

      assert {:error, changeset} = Player.create(%{ @params | game_id: game_id })
      assert [user: {"does not exist", _}] = changeset.errors
    end

    test "cannot create a player with invalid game_id" do
      %{id: user_id} = insert(:user)

      {:error, changeset} = Player.create(%{ @params | user_id: user_id })
      assert [game: {"does not exist", _}] = changeset.errors
    end

    test "cannot create two Players with the same color for both games" do
      player = insert(:player)
      {:error, changeset} =
        Player.create(%{@params | game_id: player.game_id, color: player.color})
      assert [color: {"has already been taken", _}] = changeset.errors
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
