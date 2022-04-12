defmodule TheLittleThinkersSpace.Repo.Migrations.DropLittleThinkerCrewTable do
  use Ecto.Migration

  def change do
    drop table(:little_thinker_crew)
  end
end
