defmodule TheLittleThinkersSpace.Repo.Migrations.CreateRelationshipsTable do
  use Ecto.Migration

  def change do
    create table(:relationships) do
      add :little_thinker_id, references(:users, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :type, :string

      timestamps()
    end

    create unique_index(:relationships, [:little_thinker_id, :user_id])
    create index(:relationships, :user_id)
  end
end
