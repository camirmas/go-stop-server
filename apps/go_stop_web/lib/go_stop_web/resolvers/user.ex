defmodule GoStopWeb.Resolvers.User do
  import GoStopWeb.Errors

  def list_users(_parent, _args, _resolution) do
    {:ok, GoStop.User.list(preload: preloads())}
  end

  def create_user(_parent, data, _resolution) do
    case GoStop.User.create(data) do
      {:ok, user} ->
        {:ok, token, _claims} = GoStopWeb.Guardian.encode_and_sign(user)
        user = user |> Map.from_struct() |> Map.put(:token, token)
        {:ok, user}

      {:error, changeset} -> changeset_errors(changeset)
    end
  end

  def get_user(_parent, data, _resolution) do
    {:ok, GoStop.User.get_by(data, preload: preloads())}
  end

  def get_current_user(_parent, _data, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end
  def get_current_user(_parent, _data, _resolution) do
    authentication_error()
  end

  defp preloads do
    :games
  end
end
