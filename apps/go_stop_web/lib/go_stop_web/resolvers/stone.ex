defmodule GoStopWeb.Resolvers.Stone do
  alias GoStop.Stone

  def add_stone(_parent, data, _resolution) do
    case GoStop.Stone.create(data) do
      {:ok, _} = stone -> stone
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  def remove_stone(_parent, %{id: id}, _resolution) do
    case GoStop.Stone.delete(id) do
      {:ok, _} = stone -> stone
      {:error, "Failed: Stone does not exist"} = err -> err
      {:error, changeset} -> {:error, "Failed: #{parse_errors(changeset)}"}
    end
  end

  defp parse_errors(changeset) do
    Enum.map(changeset.errors, fn {k, {v, _}} ->
      "#{k} #{v}"
    end)
  end
end
