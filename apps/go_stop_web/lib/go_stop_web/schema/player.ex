defmodule GoStopWeb.Schema.Player do
  use Absinthe.Schema.Notation

  object :player do
    field :id, :id
    field :user, :user
    field :game, :game
  end
end
