defmodule TheLittleThinkersSpace.Repo.Migrations.AddNotNullConstraintToLastName do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :last_name, :string, null: false, from: :string
    end
  end
end
