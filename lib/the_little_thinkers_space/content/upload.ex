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
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs,
      message: "This box must not be empty!"
    )
    |> validate_inclusion(:file_type, @valid_file_types, message: "Wrong file type!")
  end

  def authorize(_, %User{role: "Admin"}, _), do: :ok
  def authorize(_, %User{role: "The Little Thinker"}, _), do: :ok
  def authorize(action, %User{}, %Upload{}) when action in [:show, :index], do: :ok
  def authorize(_action, _user, _upload), do: :error
end
