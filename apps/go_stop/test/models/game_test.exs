defmodule GoStop.GameTest do
  use GoStop.DataCase, async: true

  alias GoStop.{Game, Repo}

  @params %{status: "pending", player_turn_id: nil}

  test "#list" do
    game = insert(:game)

    assert Game.list == [game]
  end

  test "#list_for_user" do
    player = insert(:player) |> Repo.preload(:user)

    assert Game.list_for_user(player.user) == [player.game]
  end

  describe "#get" do
    setup do
      [game: insert(:game)]
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
      game = Repo.preload(game, :players)

      assert game.status == "pending"
      refute game.player_turn_id
    end

    test "with invalid status an error and changeset" do
      {:error, changeset} = Game.create(%{status: "bad"})
      assert changeset.errors == [status: {"is invalid", [validation: :inclusion]}]
    end
  end

  describe "#update" do
    test "with valid params returns an updated `Game`" do
      game = insert(:game) |> Repo.preload(:players)
      assert {:ok, _} = Game.update(game, @params)
    end

    test "with valid Player turn returns an error changeset" do
      player = insert(:player) |> Repo.preload([game: [:players]])
      assert {:ok, _} = Game.update(player.game, %{@params | player_turn_id: player.id})
    end

    test "with invalid Player turn returns an error changeset" do
      game = insert(:game) |> Repo.preload(:players)
      assert {:error, _} = Game.update(game, %{@params | player_turn_id: 1})
    end
  end
end
