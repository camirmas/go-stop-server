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

  @required_fields [:x, :y, :color]

  # Empty: 0
  # Black: 1
  # White: 2
  @accepted_colors [0, 1, 2]

  def create(attrs) do
    %Stone{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:color, @accepted_colors)
    |> assoc_constraint(:game)
  end
end
