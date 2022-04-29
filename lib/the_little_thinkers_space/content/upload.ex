defmodule TheLittleThinkersSpace.Content.Upload do
  @moduledoc """
  Files that a little thinker uploads, can be picture or video.
  Stored in database as a binary then sent to the page to be rendered.
  This will likely not scale well and will eventually be stored in S3
  """
  use Ecto.Schema
  use Phoenix.Component
  import Ecto.Changeset
  alias TheLittleThinkersSpace.Accounts.User
  alias TheLittleThinkersSpace.Content.Upload

  @behaviour Bodyguard.Policy

  @orientation_options ["Landscape", "Portrait"]
  @required_attrs [:file_type, :title, :description, :orientation, :path]
  @valid_image_types ["image/jpeg", "image/jpg", "image/png"]
  @valid_video_types ["video/mp4", "video/quicktime"]
  @valid_file_types @valid_image_types ++ @valid_video_types

  def orientation_options, do: @orientation_options
  def valid_image_types, do: @valid_image_types
  def valid_video_types, do: @valid_video_types
  def valid_file_types, do: @valid_file_types

  schema "uploads" do
    field :description, :string
    field :file_type, :string
    field :title, :string
    field :orientation, :string
    field :path, :string
    field :thumbnail, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:thumbnail | @required_attrs])
    |> validate_required(@required_attrs,
      message: "This box must not be empty!"
    )
    |> validate_inclusion(:file_type, @valid_file_types, message: "Wrong file type!")
    |> unique_constraint(:path, message: "This file has already been uploaded!")
    |> unique_constraint(:thumbnail, message: "Thumbnail has already been created!")
  end

  # Authorization for the Little Thinker in relation to their own uploads
  def authorize(:index, %User{role: "The Little Thinker", id: id}, {_uploads, little_thinker_id})
      when id == little_thinker_id,
      do: :ok

  def authorize(:new, %User{role: "The Little Thinker", id: id}, little_thinker_id)
      when id == little_thinker_id,
      do: :ok

  def authorize(:create, %User{role: "The Little Thinker", id: id}, {_uploads, little_thinker_id})
      when id == little_thinker_id,
      do: :ok

  def authorize(action, %User{role: "The Little Thinker", id: id}, %Upload{user_id: id})
      when action in [:show, :edit, :update, :delete],
      do: :ok

  def authorize(:show, %User{little_thinkers: little_thinkers}, %Upload{
        user_id: little_thinker_id
      }) do
    little_thinkers
    |> Enum.map(& &1.id)
    |> Enum.member?(little_thinker_id)
    |> case do
      true -> :ok
      false -> :error
    end
  end

  def authorize(:index, %User{little_thinkers: little_thinkers}, {_uploads, little_thinker_id}) do
    little_thinkers
    |> Enum.map(& &1.id)
    |> Enum.member?(little_thinker_id)
    |> case do
      true -> :ok
      false -> :error
    end
  end

  def authorize(_action, _user, _upload), do: :error
end
