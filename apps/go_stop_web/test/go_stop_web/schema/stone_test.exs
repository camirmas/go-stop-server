defmodule GoStopWeb.Schema.StoneTest do
  use GoStopWeb.ConnCase, async: true
  import GoStopWeb.Guardian

  alias GoStop.{Repo, Game}

  describe "addStone" do
    setup do
      player = insert(:player, %{color: "white"})
      insert(:player, %{game: player.game, color: "black"})

      {:ok, token, _} = encode_and_sign(player.user, %{}, token_type: :access)

      [token: token, player: player]
    end

    test "creates a stone with valid params and authentication, and changes turn",
      %{conn: conn, token: token, player: player} do
        {:ok, game} =
          player.game
          |> Repo.preload(:players)
          |> Game.update(%{player_turn_id: player.id})

        query = """
        mutation AddStone {
          addStone(gameId: #{game.id}, x: 0, y: 0) {
            color
          }
        }
        """
        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert res == %{"data" => %{"addStone" => %{"color" => "white"}}}
        refute Game.get(game.id).player_turn_id == player.id
    end

    test "returns errors with wrong player turn",
      %{conn: conn, player: player, token: token} do
        query = """
        mutation AddStone {
          addStone(game_id: #{player.game.id}, x: 0, y: 0) {
            id
          }
        }
        """

        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert %{"errors" => [%{"message" => message}]} = res
        assert message == "Failed: player must wait a turn"
    end

    test "returns errors with invalid params",
      %{conn: conn, player: player, token: token} do
        {:ok, game} =
          player.game
          |> Repo.preload(:players)
          |> Game.update(%{player_turn_id: player.id})

        query = """
        mutation AddStone {
          addStone(game_id: #{game.id}1, x: 0, y: 0) {
            id
          }
        }
        """

        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert %{"errors" => [%{"message" => message}]} = res
        assert message == "Failed: game does not exist"
    end

    test "cannot add a Stone to an ended Game",
      %{conn: conn, player: player, token: token} do
        {:ok, game} =
          player.game
          |> Repo.preload(:players)
          |> Game.update(%{player_turn_id: player.id, status: "complete"})

        query = """
        mutation AddStone {
          addStone(game_id: #{game.id}, x: 0, y: 0) {
            id
          }
        }
        """

        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert %{"errors" => [%{"message" => message}]} = res
        assert message == "Failed: game has ended"
    end
  end
end
