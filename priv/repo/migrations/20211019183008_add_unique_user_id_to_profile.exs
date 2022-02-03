defmodule TheLittleThinkersSpace.Repo.Migrations.AddUniqueUserIdToProfile do
  use Ecto.Migration

  def change do
    drop index(:profiles, [:user_id])
    create unique_index(:profiles, [:user_id])
  end
end
