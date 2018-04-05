defmodule GoStopWeb.SchemaTest do
  use GoStopWeb.ConnCase, async: true

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
      {
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
      {
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

  describe "createPlayer" do
    setup do
      user = insert(:user)
      game = insert(:game)

      [user: user, game: game]
    end

    test "creates a Player with valid params", %{conn: conn, user: %{id: user_id}, game: %{id: game_id}} do
      query = """
      {
        createPlayer(userId: #{user_id}, gameId: #{game_id}, status: "user-pending") {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"data" => %{"createPlayer" => %{"id" => _}}} = res
    end

    test "returns errors with invalid params", %{conn: conn, user: %{id: user_id}, game: %{id: game_id}} do
      query = """
      {
        createPlayer(userId: #{user_id}1, gameId: #{game_id}, status: "user-pending") {
          id
        }
      }
      """

      res =
        conn
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
      [game: insert(:game)]
    end

    test "creates a stone with valid params", %{conn: conn, game: game} do
      query = """
      {
        addStone(gameId: #{game.id}, x: 0, y: 0, color: 0) {
          color
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"addStone" => %{"color" => 0}}}
    end

    test "returns errors with invalid params", %{conn: conn, game: game} do
      query = """
      {
        addStone(game_id: #{game.id}1, x: 0, y: 0, color: 0) {
          id
        }
      }
      """

      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: game does not exist"
    end
  end

  describe "removeStone" do
    setup do
      game = insert(:game)
      {:ok, stone} = GoStop.Stone.create(%{game_id: game.id, x: 0, y: 0, color: 0})

      [stone: stone]
    end

    test "removes the stone with proper id", %{conn: conn, stone: stone} do
      query = """
      {
        removeStone(id: #{stone.id}) {
          color
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"removeStone" => %{"color" => 0}}}
    end

    test "returns an error with invalid id", %{conn: conn, stone: stone} do
      query = """
      {
        removeStone(id: #{stone.id}1) {
          id
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: Stone does not exist"
    end
  end
end
