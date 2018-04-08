defmodule GoStopWeb.Schema.PlayerTest do
  use GoStopWeb.ConnCase, async: true

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
end
