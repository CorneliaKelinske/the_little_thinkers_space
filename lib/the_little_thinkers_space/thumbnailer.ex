defmodule TheLittleThinkersSpace.Thumbnailer do
  @moduledoc """
  This module creates a thumbnail image from the uploaded videos
  """

  alias TheLittleThinkersSpace.{Content.Upload, UploadPathsHelper}

  @valid_image_types Upload.valid_image_types()
  @valid_video_types Upload.valid_video_types()

  def create_thumbnail(%Plug.Upload{content_type: content_type}, path)
      when content_type in @valid_video_types do
    case UploadPathsHelper.thumbnail_path(path) do
      {:ok, thumbnail_path} ->
        Thumbnex.create_thumbnail(
          path,
          thumbnail_path,
          maximum_width: 320,
          maximum_height: 320
        )

        {:ok, thumbnail_path}

      {:error, :no_thumbnail_path} ->
        {:error, :no_thumbnail_path}
    end
  end

  def create_thumbnail(%Plug.Upload{content_type: content_type}, _path)
      when content_type in @valid_image_types do
    {:ok, nil}
  end
end
