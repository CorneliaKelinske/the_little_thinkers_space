defmodule TheLittleThinkersSpace.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheLittleThinkersSpace.Content` context.
  """
  import TheLittleThinkersSpace.AccountsFixtures

  @create_image_attrs %{
    description: "some description",
    file: "some file",
    file_type: "image/jpg",
    title: "some title",
    orientation: "Landscape",
    path: "test/support/Lifting.jpg"
  }

  @doc """
  Generate a upload.
  """
  def upload_fixture(attrs \\ %{}) do
    user = user_fixture()
    attrs = Enum.into(attrs, @create_image_attrs)
    {:ok, upload} = TheLittleThinkersSpace.Content.create_upload(user, attrs)
    upload
  end
end
