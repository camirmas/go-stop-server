defmodule GoStop.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias GoStop.{Repo, User, Game, Player}

  schema "players" do
    field(:status, :string)
    embeds_one(:stats, Player.Stats)
    belongs_to(:user, User)
    belongs_to(:game, Game)

    timestamps()
  end

  @fields [:user_id, :game_id, :status]
  @accepted_statuses ~w(user-pending active)

  def create(attrs) do
    %Player{}
    |> changeset(attrs)
    |> Repo.insert()
 end

  def get(id) do
    Repo.get(Player, id) |> Repo.preload([:user])
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:status, @accepted_statuses)
    |> assoc_constraint(:user)
    |> assoc_constraint(:game)
    |> cast_embed(:stats, with: &Player.Stats.changeset/2)
  end
end
