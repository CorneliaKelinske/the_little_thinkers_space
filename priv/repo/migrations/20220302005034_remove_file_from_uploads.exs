defmodule TheLittleThinkersSpace.Repo.Migrations.RemoveFileFromUploads do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      remove :file
    end
  end
end
