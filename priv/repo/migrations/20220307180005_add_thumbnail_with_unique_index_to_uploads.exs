defmodule TheLittleThinkersSpace.Repo.Migrations.AddThumbnailWithUniqueIndexToUploads do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :thumbnail, :string
    end

    create unique_index(:uploads, [:thumbnail])
  end
end
