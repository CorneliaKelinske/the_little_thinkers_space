defmodule TheLittleThinkersSpace.Accounts.Profile do
  @moduledoc """
  Each user of the TheLittleThinkersSpace can create one profile.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias TheLittleThinkersSpace.Accounts.{Profile, User}

  @behaviour Bodyguard.Policy

  schema "profiles" do
    field :animal, :string
    field :birthday, :date
    field :book, :string
    field :color, :string
    field :first_name, :string
    field :food, :string
    field :future, :string
    field :joke, :string
    field :last_name, :string
    field :movie, :string
    field :nickname, :string
    field :song, :string
    field :superhero, :string
    belongs_to :user, User

    timestamps()
  end

  @required_attrs [
    :first_name,
    :last_name,
    :nickname,
    :birthday,
    :color,
    :animal,
    :food,
    :superhero,
    :song,
    :movie,
    :book,
    :future,
    :joke
  ]

  @cast_attrs [:user_id | @required_attrs]

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, @cast_attrs)
    |> validate_required(@required_attrs, message: "This field must not be empty!")
    |> unique_constraint(:user_id)
  end

  def authorize(_, %User{role: "Admin"}, _profile), do: :ok

  # Authorizes the Little Thinker to see the profiles of their crew and of the little thinkers that they are following
  def authorize(
        action,
        %User{role: "The Little Thinker", little_thinkers: little_thinkers, crews: crews},
        %Profile{user_id: user_id}
      )
      when action in [:index, :show] do
    (crews ++ little_thinkers)
    |> Enum.map(& &1.id)
    |> Enum.member?(user_id)
    |> case do
      true -> :ok
      false -> :error
    end
  end

  # Note: I did not implement authorization for create, since a profile that is in the process of
  # being created would not have user_id yet. This authorizes users to do things with their own profiles.
  def authorize(action, %User{id: id}, %Profile{user_id: id})
      when action in [:show, :edit, :update, :delete],
      do: :ok

  # Authorizes users to view profiles of little thinkers they are following
  def authorize(:show, %User{little_thinkers: little_thinkers}, %Profile{user_id: user_id}) do
    little_thinkers
    |> Enum.map(& &1.id)
    |> Enum.member?(user_id)
    |> case do
      true -> :ok
      false -> :error
    end
  end

  def authorize(_action, _, _profile), do: :error
end
