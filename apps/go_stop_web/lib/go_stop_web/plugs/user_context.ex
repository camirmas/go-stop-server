defmodule GoStopWeb.Plugs.UserContext do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
      {:ok, current_user} <- authorize(token) do
        %{current_user: current_user}
      else
        _ -> %{}
      end
  end

  defp authorize(token) do
    case GoStopWeb.Guardian.resource_from_token(token) do
      nil ->
        {:error, :unauthorized}
      user ->
        {:ok, user}
    end
  end
end
