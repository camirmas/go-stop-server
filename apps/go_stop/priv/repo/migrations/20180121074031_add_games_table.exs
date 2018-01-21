defmodule GoStop.Repo.Migrations.AddGamesTable do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :status, :string, null: false

      timestamps()
    end
  end
end
