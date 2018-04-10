defmodule GoStop.Player do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, User, Game, Player}

  schema "players" do
    field(:status, :string)
    field(:color, :string)
    field(:has_passed, :boolean, default: false)
    embeds_one(:stats, Player.Stats)
    belongs_to(:user, User)
    belongs_to(:game, Game)

    timestamps()
  end

  @fields [:user_id, :game_id, :status, :color, :has_passed]
  @accepted_statuses ~w(user-pending active)
  @accepted_colors ~w(black white)

  def list_for_game(game, preload: preload) do
    query = from p in Player,
      where: p.game_id == ^game.id,
      preload: ^preload

    Repo.all(query)
  end
  def list_for_game(game) do
    query = from p in Player,
      where: p.game_id == ^game.id

    Repo.all(query)
  end

  def create(attrs) do
    %Player{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(player, attrs) do
    player
    |> changeset(attrs)
    |> Repo.update()
  end

  def get(id) do
    Repo.get(Player, id)
  end
  def get(id, preload: preload) do
    case get(id) do
      nil -> nil
      player -> player |> Repo.preload(preload)
    end
  end

  def get_by(attrs) do
    Repo.get_by(Player, attrs)
  end

  def get_opponent(player) do
    %{game: game} = player |> Repo.preload(game: [:players])
    Enum.find(game.players, fn p -> p.id != player.id end)
  end

  def is_turn?(player) do
    player = player |> Repo.preload(:game)
    player.id == player.game.player_turn_id
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:status, @accepted_statuses)
    |> validate_inclusion(:color, @accepted_colors)
    |> assoc_constraint(:user)
    |> assoc_constraint(:game)
    |> unique_constraint(:color, name: :players_game_id_color_index)
    |> cast_embed(:stats, with: &Player.Stats.changeset/2)
  end
end
