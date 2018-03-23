defmodule GoStop.GameTest do
  use GoStop.DataCase, async: true

  alias GoStop.{Game}

  @params %{
    status: "pending"
  }

  test "#list" do
    {:ok, game} = Game.create(@params)

    assert [^game] = Game.list
  end

  describe "#get" do
    setup do
      {:ok, game} = Game.create(@params)

      [game: game]
    end

    test "with valid id returns a `Game`", %{game: game} do
      assert game == Game.get(game.id)
    end

    test "with invalid id returns `nil`", %{game: game} do
      assert is_nil(Game.get(game.id + 1))
    end
  end

  describe "#create" do
    test "with valid params returns a `Game`" do
      {:ok, game} = Game.create(@params)

      assert game.status == @params.status
    end

    test "with no params returns an error and changeset" do
      {:error, changeset} = Game.create(%{})
      refute is_valid(changeset)
    end

    test "with invalid status returns an error and changeset" do
      {:error, changeset} = Game.create(%{@params | status: "wrong"})
      refute is_valid(changeset)
    end
  end
end
