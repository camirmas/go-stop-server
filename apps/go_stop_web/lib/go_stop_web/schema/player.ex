defmodule GoStopWeb.Schema.Player do
  use Absinthe.Schema.Notation

  object :player do
    field :id, :id
    field :user, :user
  end
end
