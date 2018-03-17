defmodule GoStopWeb.Resolvers.User do
  def list_users(_parent, _args, _resolution) do
    {:ok, GoStop.User.list(preload: preloads())}
  end

  def create_user(_parent, data, _resolution) do
    case GoStop.User.create(data) do
      {:ok, _} = user -> user
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  def get_user(_parent, data, _resolution) do
    {:ok, GoStop.User.get_by(data, preload: preloads())}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end

  defp preloads do
    :games
  end
end
