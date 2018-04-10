defmodule GoStopWeb.Errors do
  def authentication_error do
    {:error, "Failed: user not authenticated"}
  end

  def wrong_turn_error do
    {:error, "Failed: player must wait a turn"}
  end

  def game_not_found_error do
    {:error, "Failed: game does not exist"}
  end

  def changeset_errors(changeset) do
    {:error, "Failed: #{parse_errors(changeset)}"}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end
end
