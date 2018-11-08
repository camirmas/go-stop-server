defmodule GoStopWeb.Schema.UserTest do
  use GoStopWeb.ConnCase, async: true
  import GoStopWeb.Guardian

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

  describe "currentUser" do
    setup do
      user = insert(:user, %{username: "dude"})

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      [user: user, token: token]
    end

    test "gets the current User", %{conn: conn, user: %{username: username}, token: token} do
      query = """
      {
        currentUser {
          username
        }
      }
      """
      res =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post("/api", %{query: query})
        |> json_response(200)

      assert res == %{"data" => %{"currentUser" => %{"username" => username}}}
    end

    test "returns nil if the User is not found", %{conn: conn} do
      query = """
      {
        currentUser {
          username
        }
      }
      """
      res =
        conn
        |> post("/api", %{query: query})
        |> json_response(200)

      assert %{"errors" => [%{"message" => message}]} = res
      assert message == "Failed: User not authenticated"
    end
  end
end
