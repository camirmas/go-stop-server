defmodule GoStopWeb.Resolvers.Stone do
  alias GoStop.Stone

  def add_stone(_parent, data, %{context: %{current_user: _}}) do
    case GoStop.Stone.create(data) do
      {:ok, _} = stone -> stone
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  def add_stone(_, _, _) do
    {:error, "Failed: user not authenticated"}
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end
end
