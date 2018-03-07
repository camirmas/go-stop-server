defmodule GoStopWeb.Schema do
  use Absinthe.Schema
  import_types GoStopWeb.Schema.User

  alias GoStopWeb.Resolvers

  query do
    @desc "Get a User by username"
    field :user, :user do
      arg :username, non_null(:string)
      resolve &Resolvers.User.get_user/3
    end
  end
end
