defmodule TheLittleThinkersSpace.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :first_name, :string
      add :last_name, :string
      add :nickname, :string
      add :birthday, :date
      add :color, :string
      add :animal, :string
      add :food, :string
      add :superhero, :string
      add :song, :string
      add :movie, :string
      add :book, :string
      add :future, :string
      add :joke, :string
      add :belongs_to_lt, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:profiles, [:user_id])
  end
end
