defmodule GoStopWeb.Resolvers.User do
  def get_user(_parent, data, _resolution) do
    {:ok, GoStop.User.get_by(data, preload: preloads())}
  end

  def list_users(_parent, _args, _resolution) do
    {:ok, GoStop.User.list(preload: preloads())}
  end

  defp preloads do
    :games
  end
end
