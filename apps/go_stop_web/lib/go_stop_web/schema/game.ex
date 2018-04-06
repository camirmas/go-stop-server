defmodule GoStopWeb.Schema.Game do
  use Absinthe.Schema.Notation

  object :game do
    field :id, :id
    field :status, :string
    field :players, list_of(:player)
    field :stones, list_of(:stone)
    field :player_turn_id, :id
  end
end
