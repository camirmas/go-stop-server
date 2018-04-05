defmodule GoStopWeb.Schema.User do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :token, :string
    field :username, :string
    field :email, :string
    field :games, list_of(:game)
  end
end
