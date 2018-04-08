defmodule GoStopWeb.Schema.AuthTest do
  use GoStopWeb.ConnCase, async: true

  alias GoStop.User

  describe "logIn" do
    setup do
      {:ok, user} = User.create(%{
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
end
