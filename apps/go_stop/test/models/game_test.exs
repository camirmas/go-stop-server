defmodule GoStop.GameTest do
  use GoStop.DataCase

  alias GoStop.{Game}

  @params %{
    status: "pending"
  }

  describe "#create" do
    test "with valid params" do
      {:ok, game} = Game.create(@params)

      assert game.status == @params.status
    end

    test "with no params" do
      {:error, changeset} = Game.create(%{})
      refute is_valid(changeset)
    end

    test "with invalid status" do
      {:error, changeset} = Game.create(%{@params | status: "wrong"})
      refute is_valid(changeset)
    end
  end
end
