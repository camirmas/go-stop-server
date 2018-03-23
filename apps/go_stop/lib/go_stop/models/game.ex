defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, Game, User, Player, Stone}
  alias Ecto.Multi

  schema "games" do
    field(:status, :string)
    has_many(:players, Player)
    has_many(:stones, Stone)
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
    with {:ok, result} <-
      Multi.new
      |> Multi.run(:game, fn _ ->
        %Game{}
        |> changeset(attrs)
        |> Repo.insert()
      end)
      |> Multi.run(:stones, fn %{game: game} ->
        Stone.bulk_create(game)
      end)
      |> Repo.transaction
    do
      {:ok, result.game}
    end
  end

  def update(attrs) do
    %Game{}
    |> changeset(attrs)
    |> Repo.update()
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

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> cast_assoc(:stones)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @accepted_statuses)
  end
end
