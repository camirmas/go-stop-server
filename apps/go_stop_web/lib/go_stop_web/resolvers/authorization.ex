defmodule GoStopWeb.Resolvers.Authorization do
  def log_in(_parent, %{username: username, password: password}, _resolution) do
    case GoStop.User.get_by(%{username: username}) do
      nil ->
        {:error, "Failed: Could not find User with username: #{username}"}
      user ->
        check_password(password, user)
    end
  end

  defp check_password(password, user) do
    if Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
      {:ok, token, _claims} = GoStopWeb.Guardian.encode_and_sign(user)
      {:ok, %{token: token}}
    else
      {:error, "Failed: invalid username/password combination"}
    end
  end
end
