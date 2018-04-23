defmodule GoStop.Player.Stats do
  use Ecto.Schema
  import Ecto.Changeset

  alias GoStop.{Repo, Player}

  @accepted_fields [:captured_stones]

  @primary_key false
  embedded_schema do
    field :captured_stones, :integer, default: 0
  end

  def capture_stone(nil) do
    capture_stone(%Player.Stats{})
  end
  def capture_stone(stats) do
    stats
    |> changeset(%{captured_stones: stats.captured_stones + 1})
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @accepted_fields)
  end
end
