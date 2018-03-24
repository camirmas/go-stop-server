defmodule GoStopWeb.Schema.Stone do
  use Absinthe.Schema.Notation

  object :stone do
    field :id, :id
    field :x, :integer
    field :y, :integer
    field :color, :integer
  end
end
