defmodule GoStopWeb.Schema do
  use Absinthe.Schema
  import_types GoStopWeb.Schema.User
  import_types GoStopWeb.Schema.Game
  import_types GoStopWeb.Schema.Player
  import_types GoStopWeb.Schema.Stone

  alias GoStopWeb.Resolvers

  query do
    @desc "Get all Users"
    field :users, list_of(:user) do
      resolve &Resolvers.User.list_users/3
    end

    @desc "Create a User"
    field :create_user, :user do
      arg :username, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :password_confirmation, non_null(:string)

      resolve &Resolvers.User.create_user/3
    end

    @desc "Get a User by username"
    field :user, :user do
      arg :username, non_null(:string)
      resolve &Resolvers.User.get_user/3
    end

    @desc "Get all Games"
    field :games, list_of(:game) do
      resolve &Resolvers.Game.list_games/3
    end

    @desc "Create a Game"
    field :create_game, :game do
      arg :status, non_null(:string)

      resolve &Resolvers.Game.create_game/3
    end

    @desc "Get a Game by id"
    field :game, :game do
      arg :id, non_null(:id)
      resolve &Resolvers.Game.get_game/3
    end

    @desc "Create a Player"
    field :create_player, :player do
      arg :user_id, non_null(:id)
      arg :game_id, non_null(:id)
      arg :status, non_null(:string)

      resolve &Resolvers.Player.create_player/3
    end

    @desc "Get a Player by id"
    field :player, :player do
      arg :id, non_null(:id)
      resolve &Resolvers.Player.get_player/3
    end

    @desc "Add Stone to Game"
    field :add_stone, :stone do
      arg :x, non_null(:integer)
      arg :y, non_null(:integer)
      arg :color, non_null(:integer)
      arg :game_id, non_null(:id)

      resolve &Resolvers.Stone.add_stone/3
    end

    @desc "Remove Stone"
    field :remove_stone, :stone do
      arg :id, non_null(:id)

      resolve &Resolvers.Stone.remove_stone/3
    end
  end
end
