defmodule TheLittleThinkersSpace.Repo.Migrations.AddNotNullConstraintToPath do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      modify :path, :string, null: false, from: :string
    end
  end
end
