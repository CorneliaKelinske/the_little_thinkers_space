defmodule TheLittleThinkersSpace.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :file, :binary
      add :file_type, :string
      add :title, :string
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:uploads, [:user_id])
  end
end
