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
    field :belongs_to_lt, :boolean, default: false
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
    :joke,
    :belongs_to_lt
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

  def authorize(action, %User{role: "The Little Thinker"}, _profile)
      when action in [:index, :show],
      do: :ok

  # Note: I did not implement authorization for create, since a profile that is in the process of
  # being created would not have user_id yet.
  def authorize(action, %User{id: id}, %Profile{user_id: id})
      when action in [:show, :edit, :update, :delete],
      do: :ok

  def authorize(:show, %User{}, %Profile{belongs_to_lt: true}), do: :ok
  def authorize(_action, _, __profile), do: :error
end
