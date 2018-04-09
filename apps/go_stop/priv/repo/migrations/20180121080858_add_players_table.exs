defmodule GoStop.Repo.Migrations.AddPlayersTable do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :user_id, references(:users)
      add :game_id, references(:games)
      add :status, :string, null: false
      add :color, :string, null: false
      add :stats, :map
      add :has_passed, :boolean, default: false

      timestamps()
    end

    create index(:players, :user_id)
    create index(:players, :game_id)
    create unique_index(:players, [:game_id, :color])
  end
end
