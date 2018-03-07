defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias GoStop.{Repo, Game, User}

  schema "games" do
    field(:status, :string)
    many_to_many(:users, User, join_through: "players")

    timestamps()
  end

  @required_fields [:status]
  @accepted_statuses ~w(pending active complete)

  @doc """
  Creates a Game as well as related Player.
  """
  def create(attrs) do
    %Game{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get(id) do
    Repo.get(Game, id)
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @accepted_statuses)
  end
end
