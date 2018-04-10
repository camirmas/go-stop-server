defmodule GoStopWeb.Schema.PlayerTest do
  use GoStopWeb.ConnCase, async: true

  import GoStopWeb.Guardian

  alias GoStop.{Repo, Player, Game}

  describe "player" do
    setup do
      [player: insert(:player)]
    end

    test "gets a Player by id", %{conn: conn, player: %{id: id}} do
      query = """
      {
        player(id: #{id}) {
          id
        }
      }
      """

      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"player" => %{"id" => "#{id}"}}}
    end

    test "returns nil if the Player is not found", %{conn: conn, player: %{id: id}} do
      query = """
      {
        player(id: #{id}1) {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"player" => nil}}
    end
  end

  describe "pass" do
    setup do
      game = insert(:game)
      player = insert(:player, %{game: game, color: "black"})
      opponent = insert(:player, %{game: game, color: "white"})
      game = game |> Repo.preload(:players)
      {:ok, _} = Game.update(game, %{player_turn_id: player.id})

      {:ok, token, _} = encode_and_sign(player.user, %{}, token_type: :access)

      [token: token, player: player, opponent: opponent]
    end

    test "allows a Player to pass on a turn",
      %{conn: conn, player: player, opponent: opponent, token: token} do
        query = """
        mutation Pass {
          pass(gameId: #{player.game_id}) {
            id
          }
        }
        """
        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert res == %{"data" => %{"pass" => %{"id" => "#{player.id}"}}}
        player = Player.get(player.id, preload: [:game])
        assert player.has_passed
        assert player.game.player_turn_id == opponent.id
    end

    test "ends the Game when both Players pass",
      %{conn: conn, player: player, opponent: opponent, token: token} do
        {:ok, _} = Player.update(opponent, %{has_passed: true})
        query = """
        mutation Pass {
          pass(gameId: #{player.game_id}) {
            id
          }
        }
        """
        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert res == %{"data" => %{"pass" => %{"id" => "#{player.id}"}}}
        game = Game.get(player.game_id)
        assert game.status == "complete"
    end
  end
end
