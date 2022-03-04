defmodule TheLittleThinkersSpace.UploadHandler do
  @moduledoc """
  This module includes the logic for processing the data received from the upload form and
  storing the upload both in the database and in the file directory
  """
  alias TheLittleThinkersSpace.{DataPath, UploadPathsHelper}

  def store_upload(%Plug.Upload{filename: filename, path: path}, user_id) do
    maybe_create_user_directory(user_id)
    storage_path = "#{DataPath.set_data_path()}/#{user_id}/#{filename}"

    case File.cp(path, "#{storage_path}") do
      :ok -> {:ok, storage_path}
      {:error, _} -> {:error, :file_not_saved}
    end
  end

  def delete_upload(%{path: path}) do
    delete_path = UploadPathsHelper.delete_path(DataPath.set_data_path())
    full_delete_path = "#{delete_path}#{path}"
    File.rm(full_delete_path)
  end

  defp maybe_create_user_directory(user_id) do
    case File.exists?("#{DataPath.set_data_path()}/#{user_id}") do
      false -> File.mkdir("#{DataPath.set_data_path()}/#{user_id}")
      true -> :ok
    end
  end
end
