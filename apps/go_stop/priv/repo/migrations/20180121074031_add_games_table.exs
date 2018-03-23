defmodule GoStop.Repo.Migrations.AddGamesTable do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :status, :string, null: false
      add :state, :map
      add :player_turn_id, :integer

      timestamps()
    end
  end
end
