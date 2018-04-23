defmodule GoStop.PlayerStatsTest do
  use GoStop.DataCase, async: true

  alias GoStop.Player

  test "it can increment captured_stones" do
    player = insert(:player)

    {:ok, player} = Player.capture_stone(player)
    assert player.stats.captured_stones == 1
  end
end
