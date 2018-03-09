defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, Game, User, Player}

  schema "games" do
    field(:status, :string)
    has_many(:players, Player)

    timestamps()
  end

  @required_fields [:status]
  @accepted_statuses ~w(pending active complete)

  def list do
    Repo.all(from g in Game, preload: [players: [:user]])
  end

  @doc """
  Creates a Game as well as related Player.
  """
  def create(attrs) do
    %Game{}
    |> changeset(attrs)
    |> Repo.insert()
    |> Repo.preload(players: [:user])
  end

  def get(id) do
    Repo.get(Game, id) |> Repo.preload(players: [:user])
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @accepted_statuses)
  end
end
