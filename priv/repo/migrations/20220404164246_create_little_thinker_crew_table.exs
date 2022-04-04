defmodule TheLittleThinkersSpace.Repo.Migrations.CreateLittleThinkerCrewTable do
  use Ecto.Migration

  def change do
    create table(:little_thinker_crew) do
      add :little_thinker_id, references(:users, on_delete: :delete_all), null: false
      add :crew_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index :little_thinker_crew, [:little_thinker_id, :crew_id]
    create index :little_thinker_crew, :crew_id
  end
end
