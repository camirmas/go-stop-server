defmodule GoStop.Stone do
  use Ecto.Schema
  import Ecto.Changeset

  alias GoStop.{Stone, Repo, Game}

  schema "stones" do
    field :x, :integer
    field :y, :integer
    field :color, :integer
    belongs_to :game, Game

    timestamps()
  end

  @required_fields [:x, :y, :color, :game_id]

  # White: 0
  # Black: 1
  @accepted_colors [0, 1]

  @accepted_coords 0..18

  def create(attrs) do
    %Stone{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> assoc_constraint(:game)
    |> validate_required(@required_fields)
    |> validate_inclusion(:color, @accepted_colors)
    |> validate_inclusion(:x, @accepted_coords)
    |> validate_inclusion(:y, @accepted_coords)
  end
end
