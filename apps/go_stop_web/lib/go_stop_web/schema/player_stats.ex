defmodule GoStopWeb.Schema.PlayerStats do
  use Absinthe.Schema.Notation

  object :player_stats do
    field :captured_stones, :integer
  end
end
