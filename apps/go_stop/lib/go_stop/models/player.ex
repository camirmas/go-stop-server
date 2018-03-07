defmodule GoStop.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field(:status, :string)
    embeds_one(:stats, GoStop.Player.Stats)
    belongs_to(:user, GoStop.User)
    belongs_to(:game, GoStop.Game)

    timestamps()
  end

  @fields [:user_id, :game_id, :status]
  @accepted_statuses ~w(user-pending active)

  def create(attrs) do
    %GoStop.Player{}
    |> changeset(attrs)
    |> GoStop.Repo.insert()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:status, @accepted_statuses)
    |> assoc_constraint(:user)
    |> assoc_constraint(:game)
    |> cast_embed(:stats, with: &GoStop.Player.Stats.changeset/2)
  end
end
