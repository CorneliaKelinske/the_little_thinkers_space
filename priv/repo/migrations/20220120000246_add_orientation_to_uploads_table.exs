defmodule TheLittleThinkersSpace.Repo.Migrations.AddOrientationToUploadsTable do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :orientation, :string, null: false
    end
  end
end
