defmodule GoStopWeb.Errors do
  def authentication_error do
    build_err("User not authenticated")
  end

  def wrong_turn_error do
    build_err("Player must wait a turn")
  end

  def game_not_found_error do
    build_err("Game does not exist")
  end

  def game_complete_error do
    build_err("Game has ended")
  end

  def unauthorized_game_error do
    build_err("User is not a part of this game")
  end

  def changeset_errors(changeset) do
    changeset
    |> parse_errors
    |> build_err
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end

  defp build_err(msg) do
    {:error, "Failed: #{msg}"}
  end
end
