defmodule GoStopWeb.Schema.Game do
  use Absinthe.Schema.Notation

  object :game do
    field :id, :id
    field :status, :string
    field :players, list_of(:player)
    field :stones, list_of(:stone)
  end
end
