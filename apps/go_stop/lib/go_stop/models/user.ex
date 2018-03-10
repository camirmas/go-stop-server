defmodule GoStop.User do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias GoStop.{Repo, User}

  schema "users" do
    field(:username, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)
    field(:email, :string)
    many_to_many(:games, GoStop.Game, join_through: "players")

    timestamps()
  end

  @required_fields [:username, :email, :password]

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password, message: "Passwords do not match")
    |> unique_constraint(:email, name: :users_username_index)
    |> unique_constraint(
      :username,
      name: :users_email_index,
      message: "Username is already taken"
    )
    |> generate_encrypted_password()
  end

  def list do
    Repo.all(User)
  end
  def list(preload: preload) do
    Repo.all(from u in User, preload: ^preload)
  end

  def create(user_data) do
    registration_changeset(%User{}, user_data)
    |> Repo.insert
  end

  def get_by(field, preload: preload) do
    case get_by(field) do
      nil -> nil
      user ->
        user |> Repo.preload(preload)
    end
  end
  def get_by(%{username: username}) do
    Repo.get_by(User, username: username)
  end
  def get_by(%{id: id}) do
    Repo.get_by(User, id: id)
  end

  defp generate_encrypted_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        changeset
        |> put_change(:encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
        |> delete_change(:password) # just for safety
      _ ->
        changeset
    end
  end
end
