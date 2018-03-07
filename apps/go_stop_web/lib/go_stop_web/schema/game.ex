defmodule GoStopWeb.Schema.Game do
  use Absinthe.Schema.Notation

  object :game do
    field :id, :id
    field :status, :string
  end
end
