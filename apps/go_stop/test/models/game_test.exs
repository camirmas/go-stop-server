defmodule GoStop.GameTest do
  use GoStop.DataCase, async: true

  alias GoStop.{Game, Repo}

  setup do
    user1 = insert(:user)
    user2 = insert(:user)

    [params: %{user_id: user1.id, opponent_id: user2.id}]
  end

  test "#list", %{params: params} do
    {:ok, game} = Game.create(params)

    assert Game.list == [game]
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
    test "with valid params returns a `Game`", %{params: params} do
      {:ok, game} = Game.create(params)
      game = Repo.preload(game, :players)

      assert game.status == "pending"
      assert game.player_turn_id
      assert length(game.players) == 2
    end

    test "with invalid player 1 returns an error and changeset" do
      {:error, :player_1, changeset, _data} = Game.create(%{user_id: 1, opponent_id: 2})
      refute is_valid(changeset)
    end

    test "with invalid player 2 returns an error and changeset", %{params: params} do
      {:error, :player_2, changeset, _data} = Game.create(%{params | opponent_id: 2})
      refute is_valid(changeset)
    end
  end
end
