defmodule GoStop.Factories.Game do
  use ExMachina.Ecto, repo: GoStop.Repo

  def game_factory do
    %GoStop.Game{
      status: Enum.take_random(~w(pending active complete), 1) |> List.first
    }
  end
end
