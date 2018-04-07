defmodule GoStopWeb.SchemaTest do
  use GoStopWeb.ConnCase, async: true
  import GoStopWeb.Guardian

  alias GoStop.{Repo, Game}

  describe "users" do
    setup do
      1..5 |> Enum.map(fn _ -> insert(:player) end)

      :ok
    end

    test "gets a list of Users", %{conn: conn} do
      query = """
      {
        users {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      %{"data" => %{"users" => users}} = res
      assert length(users) == 5
    end
  end

  describe "createUser" do
    test "it creates a User with proper params", %{conn: conn} do
      query = """
      mutation CreateUser {
        createUser(username: "duder", email: "dude@dude.dude" password: "dudedude", passwordConfirmation: "dudedude") {
          id,
          token
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res["data"]["createUser"]["id"]
      assert res["data"]["createUser"]["token"]
    end

    test "it provides an error if validations fail", %{conn: conn} do
      query = """
      mutation CreateUser {
        createUser(username: "dude", email: "bad", password: "dudedude", passwordConfirmation: "dudedude") {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: email has invalid format"
    end
  end

  describe "user" do
    setup do
      [user: insert(:user, %{username: "dude"})]
    end

    test "gets a User by username", %{conn: conn, user: %{username: username}} do
      query = """
      {
        user(username: "#{username}") {
          username
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"user" => %{"username" => username}}}
    end

    test "returns nil if the User is not found", %{conn: conn, user: user} do
      query = """
      {
        user(username: "not#{user.username}") {
          username
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"user" => nil}}
    end
  end

  describe "logIn" do
    setup do
      {:ok, user} = GoStop.User.create(%{
        username: "duder",
        email: "duder@duder.duder",
        password: "dooddude",
        password_confirmation: "dooddude"
      })

      [user: user]
    end

    test "returns a token if the username/password is valid", %{conn: conn} do
      query = """
      mutation LogIn {
        logIn(username: "duder", password: "dooddude") {
          token
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"data" => %{"logIn" => %{"token" => _}}} = res
    end

    test "returns an error if the username/password is invalid", %{conn: conn} do
      query = """
      mutation LogIn {
        logIn(username: "duder", password: "dood") {
          token
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: invalid username/password combination"
    end

    test "returns an error if the user is not found", %{conn: conn} do
      query = """
      mutation LogIn {
        logIn(username: "dude", password: "dood") {
          token
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: Could not find User with username: dude"
    end
  end

  describe "games" do
    setup do
      1..5 |> Enum.map(fn _ -> insert(:player) end)

      :ok
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
      assert length(games) == 5
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

  describe "addStone" do
    setup do
      player = insert(:player)
      insert(:player, %{game: player.game})

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
          addStone(gameId: #{game.id}, x: 0, y: 0, color: 0) {
            color
          }
        }
        """
        res =
          conn
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api", %{query: query})
          |> json_response(200)

        assert res == %{"data" => %{"addStone" => %{"color" => 0}}}
        refute Game.get(game.id).player_turn_id == player.id
    end

    test "returns errors with wrong player turn",
      %{conn: conn, player: player, token: token} do
        query = """
        mutation AddStone {
          addStone(game_id: #{player.game.id}, x: 0, y: 0, color: 0) {
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
          addStone(game_id: #{game.id}1, x: 0, y: 0, color: 0) {
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
  end
end
