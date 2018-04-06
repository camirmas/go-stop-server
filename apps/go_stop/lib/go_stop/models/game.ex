defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, Game, User, Player, Stone}
  alias Ecto.Multi

  schema "games" do
    field(:status, :string)
    has_many(:players, Player)
    has_many(:stones, Stone)
    field :player_turn_id, :integer

    timestamps()
  end

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
  Creates a Game as well as related Players, and sets `player_turn_id`
  to the ID of the Player that initiated the Game.
  """
  def create(%{user_id: user_id, opponent_id: opponent_id} = attrs) do
    multi =
      Multi.new()
      |> Multi.run(:game, fn _ ->
        %Game{}
        |> changeset(attrs)
        |> put_change(:status, "pending")
        |> Repo.insert()
      end)
      |> Multi.run(:player_1, fn %{game: game} ->
        Player.create(%{status: "active", user_id: user_id, game_id: game.id})
      end)
      |> Multi.run(:player_2, fn %{game: game} ->
        Player.create(%{status: "user-pending", user_id: opponent_id, game_id: game.id})
      end)
      |> Multi.run(:updated_game, fn %{game: game, player_1: player_1} ->
        Game.update(game, %{player_turn_id: player_1.id})
      end)

    case Repo.transaction(multi) do
      {:ok, %{updated_game: game}} ->
        {:ok, game}
      err -> err
    end
  end

  @doc """
  Updates a Game.
  """
  def update(game, attrs) do
    game
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a game by ID. Allows optional preloading.
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
    |> cast(params, [:player_turn_id])
    |> cast_assoc(:stones)
    |> validate_inclusion(:status, @accepted_statuses)
  end
end
