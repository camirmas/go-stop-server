defmodule GoStopWeb.Resolvers.User do
  def get_user(_parent, %{username: username} = data, _resolution) do
    {:ok, GoStop.User.get_by(data)}
  end

  def list_users(_parent, _args, _resolution) do
    {:ok, GoStop.User.list()}
  end
end
