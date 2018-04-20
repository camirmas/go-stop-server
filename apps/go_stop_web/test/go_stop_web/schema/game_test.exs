defmodule GoStopWeb.Schema.GameTest do
  use GoStopWeb.ConnCase, async: true

  import GoStopWeb.Guardian

  describe "games" do
    setup do
      insert(:player)
      player = insert(:player)

      {:ok, token, _} = encode_and_sign(player.user, %{}, token_type: :access)

      [token: token]
    end

    test "gets a list of Games", %{conn: conn} do
      query = """
      { games { id } }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      %{"data" => %{"games" => games}} = res
      assert length(games) == 2
    end

    test "gets a User's list of Games", %{conn: conn, token: token} do
      query = """
      { games { id } }
      """
      res =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post("/api", %{query: query})
        |> json_response(200)

      %{"data" => %{"games" => games}} = res
      assert length(games) == 1
    end
  end

  describe "game" do
    setup do
      [game: insert(:game)]
    end

    test "gets a game by id", %{conn: conn, game: %{id: id}} do
      query = """
      {
        game(id: #{id}) {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"game" => %{"id" => "#{id}"}}}
    end

    test "returns nil if the Game is not found", %{conn: conn, game: %{id: id}} do
      query = """
      {
        game(id: #{id}1) {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"game" => nil}}
    end
  end

  describe "createGame" do
    test "creates a game with an authorized user", %{conn: conn} do
      user = insert(:user)
      user2 = insert(:user)
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      query = """
      mutation CreateGame {
        createGame(opponentId: #{user2.id}) {
          id
        }
      }
      """
      res =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"data" => %{"createGame" => %{"id" => _}}} = res
    end

    test "returns an error when the user is unauthorized", %{conn: conn} do
      query = """
      mutation CreateGame {
        createGame(opponentId: 1) {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: user not authenticated"
    end

    test "returns an error when the user's auth token is bad", %{conn: conn} do
      query = """
      mutation CreateGame {
        createGame(opponentId: 1) {
          id
        }
      }
      """
      res =
        conn
        |> put_req_header("authorization", "Bearer bad-news")
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: user not authenticated"
    end

    test "returns an error when the opponent cannot be found", %{conn: conn} do
      user = insert(:user)
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      query = """
      mutation CreateGame {
        createGame(opponentId: 123) {
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
        assert message == "Failed: user does not exist"
    end
  end

end
