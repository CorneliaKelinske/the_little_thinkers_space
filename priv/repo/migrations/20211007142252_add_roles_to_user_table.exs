defmodule TheLittleThinkersSpace.Repo.Migrations.AddRolesToUserTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, null: false
    end
  end
end
