defmodule TheLittleThinkersSpace.Repo.Migrations.CreateUniqueIndexOnPathInUploads do
  use Ecto.Migration

  def change do
    create unique_index(:uploads, [:path])
  end
end
