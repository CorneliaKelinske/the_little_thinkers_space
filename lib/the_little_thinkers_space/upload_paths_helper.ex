defmodule TheLittleThinkersSpace.UploadPathsHelper do
  @moduledoc """
  Based on the data path set in the config files, this module creates the path
  required by Plug.Static to render the upload in the template as well as the
  path required for deleting an upload from storage
  """
  def show_path(path) do
    case is_binary(path) do
      true ->
        show_path =
          path
          |> String.replace("app/lib/the_little_thinkers_space-0.1.0/", "")
          |> String.replace("priv/static/", "/")
          |> String.replace("//", "/")

        {:ok, show_path}

      _ ->
        {:error, :no_show_path}
    end
  end

  def delete_path(path) do
    case is_binary(path) do
      true ->
        delete_path =
          path
          |> String.replace("/uploads/development", "")
          |> String.replace("/uploads/test", "")
          |> String.replace("/data", "")
          |> String.replace("//", "/")

        delete_path

      _ ->
        {:error, :no_delete_path}
    end
  end

  def thumbnail_path(path) do
    case is_binary(path) do
      true ->
        extension = Path.extname(path)
        thumbnail_path = String.replace(path, extension, ".jpg")
        thumbnail_path

      _ ->
        {:error, :no_delete_path}
    end
  end
end
