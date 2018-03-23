defmodule GoStop.StoneTest do
  use GoStop.DataCase, async: true

  alias GoStop.Stone

  @params %{
    x: 0,
    y: 0,
    color: 1, # Black
    game_id: nil
  }

  describe "#changeset" do
    test "is valid with proper params" do
      game = insert(:game)
      changeset = Stone.changeset(%Stone{}, %{@params | game_id: game.id})
      assert is_valid(changeset)
    end

    test "is invalid with improper color" do
      changeset = Stone.changeset(%Stone{}, %{@params | color: 4})
      refute is_valid(changeset)
    end

    test "is invalid with a wrong coordinate" do
      changeset = Stone.changeset(%Stone{}, %{@params | x: 40})
      refute is_valid(changeset)
    end
  end

  describe "#create" do
    test "succeeds with proper params" do
      game = insert(:game)
      assert {:ok, %Stone{}} = Stone.create(%{@params | game_id: game.id})
    end

    test "fails with invalid game" do
      assert {:error, _changeset} = Stone.create(@params)
    end
  end
end
