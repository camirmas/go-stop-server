defmodule GoStop.User do
  use Ecto.Schema
  import Ecto.Changeset

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

  defp generate_encrypted_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, Comeonin.Argon2.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
