defmodule TheLittleThinkersSpace.Repo.Migrations.RemoveBelongsToLtFromProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      remove :belongs_to_lt
    end
  end
end
