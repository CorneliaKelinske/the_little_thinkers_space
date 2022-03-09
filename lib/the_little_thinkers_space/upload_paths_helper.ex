defmodule TheLittleThinkersSpace.UploadPathsHelper do
  @moduledoc """
  Based on the data path set in the config files, this module creates the path
  required by Plug.Static to render the upload in the template as well as the
  path required for deleting an upload from storage
  """

  def show_path(path) when is_binary(path) do
    show_path =
      path
      |> String.replace("app/lib/the_little_thinkers_space-0.1.0/", "")
      |> String.replace("priv/static/", "/")
      |> String.replace("//", "/")

    {:ok, show_path}
  end

  def show_path(_), do: {:error, :no_show_path}

  def delete_path(path) when is_binary(path) do
    delete_path =
      path
      |> String.replace("/uploads/development", "")
      |> String.replace("/uploads/test", "")
      |> String.replace("/data", "")
      |> String.replace("//", "/")

    delete_path
  end

  def delete_path(_), do: {:error, :no_delete_path}

  def thumbnail_path(path) when is_binary(path) do
    extension = Path.extname(path)
    thumbnail_path = String.replace(path, extension, ".jpg")
    {:ok, thumbnail_path}
  end

  def thumbnail_path(_), do: {:error, :no_thumbnail_path}

  def thumbnail_show_path(nil), do: {:ok, nil}

  def thumbnail_show_path(path) when is_binary(path) do
    thumbnail_show_path =
      path
      |> String.replace("app/lib/the_little_thinkers_space-0.1.0/", "")
      |> String.replace("priv/static/", "/")
      |> String.replace("//", "/")

    {:ok, thumbnail_show_path}
  end
end
