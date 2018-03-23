defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, Game, User, Player}

  schema "games" do
    field(:status, :string)
    has_many(:players, Player)
    embeds_one(:state, Game.State)
    has_one(:player_turn, Player)

    timestamps()
  end

  @required_fields [:status]
  @accepted_statuses ~w(pending active complete)

  def list do
    Repo.all(Game)
  end
  def list(preload: preload) do
    Repo.all(from g in Game, preload: ^preload)
  end

  @doc """
  Creates a Game as well as related Player.
  """
  def create(attrs) do
    %Game{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get(id, preload: preload) do
    case get(id) do
      nil -> nil
      game -> game |> Repo.preload(preload)
    end
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
