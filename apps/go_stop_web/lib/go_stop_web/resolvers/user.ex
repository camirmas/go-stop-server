defmodule GoStopWeb.Resolvers.User do
  def get_user(_parent, %{username: username}, _resolution) do
    {:ok, GoStopWeb.User.get_user(username)}
  end
end
