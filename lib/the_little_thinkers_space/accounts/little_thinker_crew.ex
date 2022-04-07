defmodule TheLittleThinkersSpace.Accounts.LittleThinkerCrew do
  @moduledoc """
  Schema for the little_thinker_crew join table where the little thinker is linekd to the people (crew) who are
  able to see the little thinker's content.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "little_thinker_crew" do
    field :little_thinker_id, :id
    field :crew_id, :id

    timestamps()
  end

  @required_attrs [:little_thinker_id, :crew_id]

  def changeset(little_thinker_crew, attrs) do
    little_thinker_crew
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs, message: "This field must not be empty!")
    |> unique_constraint([:little_thinker_id, :crew_id])
  end
end
