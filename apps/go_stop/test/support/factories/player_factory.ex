defmodule GoStop.Factories.Player do
  use ExMachina.Ecto, repo: GoStop.Repo

  def create_player(attrs) do
    build(:player, attrs)
    |> GoStop.Player.create
  end

  def player_factory do
    %{
      status: ~w(user-pending active) |> Enum.take_random(1),
      user_id: create_user().id,
      game_id: create_game().id
    }
  end
end
