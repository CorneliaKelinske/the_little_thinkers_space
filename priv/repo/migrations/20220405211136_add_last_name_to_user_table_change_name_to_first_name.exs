defmodule TheLittleThinkersSpace.Repo.Migrations.AddLastNameToUserTableChangeNameToFirstName do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :last_name, :string
    end

    rename table(:users), :name, to: :first_name

    create unique_index(:users, [:first_name, :last_name])
  end
end
