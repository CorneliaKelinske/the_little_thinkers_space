defmodule TheLittleThinkersSpace.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheLittleThinkersSpace.Content` context.
  """
  alias TheLittleThinkersSpace.Content

  @create_image_attrs %{
    description: "some description",
    file: "some file",
    file_type: "image/jpg",
    title: "some title",
    orientation: "Landscape",
    path: "/test/support/Lifting.jpg"
  }

  @doc """
  Generate a upload.
  """

  def upload(%{little_thinker: little_thinker}) do
    {:ok, upload} = Content.create_upload(little_thinker, @create_image_attrs)
    %{upload: upload}
  end
end
