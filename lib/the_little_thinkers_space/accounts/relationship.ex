defmodule TheLittleThinkersSpace.Accounts.Relationship do
  @moduledoc """
  Schema for the relationships table where the little thinker is linked to the users who are
  able to see the little thinker's content and where the relationship type between a user and a little thinker
  is described
  """
  use Ecto.Schema
  import Ecto.Changeset

  @valid_types ["Parent", "Friend", "Family"]

  schema "relationships" do
    field :little_thinker_id, :id
    field :user_id, :id
    field :type, :string

    timestamps()
  end

  @required_attrs [:little_thinker_id, :user_id, :type]

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs, message: "This field must not be empty!")
    |> unique_constraint([:little_thinker_id, :user_id])
    |> validate_inclusion(:type, @valid_types)
  end
end
