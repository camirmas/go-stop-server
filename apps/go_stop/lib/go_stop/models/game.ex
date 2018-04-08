defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, Game, User, Player, Stone}

  schema "games" do
    field(:status, :string)
    has_many(:players, Player)
    has_many(:stones, Stone)
    field :player_turn_id, :integer

    timestamps()
  end

  @accepted_fields [:status, :player_turn_id]
  @required_fields [:status]
  @accepted_statuses ~w(pending active complete)

  @doc """
  Lists all Games. Allows optional preloading.
  TODO: list Games only for given User
  """
  def list(preload: preload) do
    Repo.all(from g in Game, preload: ^preload)
  end
  def list do
    Repo.all(Game)
  end

  @doc """
  Lists Games for a given User.
  """
  def list_for_user(user, preload: preload) do
    user
    |> list_for_user()
    |> Repo.preload(preload)
  end
  def list_for_user(user) do
    user
    |> assoc(:games)
    |> Repo.all
  end

  @doc """
  Creates a Game as well as related Players, and sets `player_turn_id`
  to the ID of the Player that initiated the Game.
  """
  def create(attrs) do
    %Game{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Game.
  """
  def update(game, attrs) do
    game
    |> changeset(attrs)
    |> validate_change(:player_turn_id, fn _, id -> validate_turn(game, id) end)
    |> Repo.update()
  end

  @doc """
  Gets a game by ID.
  """
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
    |> cast(params, @accepted_fields)
    |> cast_assoc(:stones)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @accepted_statuses)
  end

  defp validate_turn(game, player_turn_id) do
    player_ids = Enum.map(game.players, &(&1.id))
    if player_turn_id in player_ids do
      []
    else
      [player_turn_id: "Must be a valid Player"]
    end
  end
end
