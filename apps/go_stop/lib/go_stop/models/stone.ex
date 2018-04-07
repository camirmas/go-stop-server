defmodule GoStop.Stone do
  use Ecto.Schema
  import Ecto.Changeset

  alias GoStop.{Stone, Repo, Game}

  schema "stones" do
    field :x, :integer
    field :y, :integer
    field :color, :string
    belongs_to :game, Game

    timestamps()
  end

  @required_fields [:x, :y, :color, :game_id]

  @accepted_colors ~w(black white)

  @accepted_coords 0..18

  def create(attrs) do
    %Stone{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def delete(id) do
    case Repo.get(Stone, id) do
      nil -> {:error, "Failed: Stone does not exist"}
      stone -> Repo.delete(stone)
    end
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> assoc_constraint(:game)
    |> validate_required(@required_fields)
    |> validate_inclusion(:color, @accepted_colors)
    |> validate_inclusion(:x, @accepted_coords)
    |> validate_inclusion(:y, @accepted_coords)
    |> unique_constraint(:position, name: :stones_x_y_game_id_index)
  end
end
