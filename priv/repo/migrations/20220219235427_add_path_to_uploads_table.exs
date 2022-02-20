defmodule TheLittleThinkersSpace.Repo.Migrations.AddPathToUploadsTable do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :path, :string
    end
  end
end
