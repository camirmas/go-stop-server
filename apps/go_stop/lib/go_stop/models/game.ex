defmodule GoStop.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :status, :string
    many_to_many :users, GoStop.User, join_through: "players"

    timestamps()
  end

  @required_fields [:status]
  @accepted_statuses ~w(pending active complete)

  @doc """
  Creates a Game as well as related Player.
  """
  def create(attrs) do
    %GoStop.Game{}
    |> changeset(attrs)
    |> GoStop.Repo.insert()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @accepted_statuses)
  end
end
