defmodule GoStop.Repo.Migrations.AddStonesTable do
  use Ecto.Migration

  def change do
    create table(:stones) do
      add :x, :integer, null: false
      add :y, :integer, null: false
      add :color, :integer, null: false
      add :game_id, references(:games)

      timestamps()
    end

    create unique_index(:stones, [:x, :y, :game_id])
  end
end
