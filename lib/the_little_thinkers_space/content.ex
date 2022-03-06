defmodule TheLittleThinkersSpace.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false

  alias TheLittleThinkersSpace.{
    Accounts,
    Content.Upload,
    DataPath,
    ImageCacher,
    Repo,
    UploadPathsHelper
  }

  @doc """
  Returns the list of uploads.

  ## Examples

      iex> list_uploads()
      [%Upload{}, ...]

  """
  def list_uploads do
    from(u in Upload, select: u.id)
    |> Repo.all()
    |> Enum.reduce({[], []}, &ImageCacher.reduce_upload_ids/2)
    |> process_uncached_ids()
    |> Enum.sort(&(&1.id < &2.id))
  end

  def process_uncached_ids({uploads, uncached_ids}) do
    uncached_ids
    |> uploads_by_ids()
    |> Enum.map(&ImageCacher.maybe_save_to_cache/1)
    |> Kernel.++(uploads)
  end

  defp uploads_by_ids(ids) do
    from(u in Upload, where: u.id in ^ids) |> Repo.all()
  end

  def get_upload_from_cache_or_repo(id) do
    ImageCacher.get_upload_from_cache_or_repo(id, &get_upload!/1)
  end

  def get_upload!(id) do
    Repo.get!(Upload, id)
  end

  def get_upload(id), do: Repo.get(Upload, id)

  def store_file(%Plug.Upload{filename: filename, path: path}, user_id) do
    maybe_create_user_directory(user_id)
    storage_path = "#{DataPath.set_data_path()}/#{user_id}/#{filename}"

    case File.cp(path, "#{storage_path}") do
      :ok -> {:ok, storage_path}
      {:error, _} -> {:error, :file_not_saved}
    end
  end

  def create_upload(%Accounts.User{} = user, attrs \\ %{}) do
    %Upload{}
    |> Upload.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a upload.

  ## Examples

      iex> update_upload(upload, %{field: new_value})
      {:ok, %Upload{}}

      iex> update_upload(upload, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_upload(%Upload{} = upload, attrs) do
    ImageCacher.delete_from_cache(upload.id)

    upload
    |> Upload.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a upload.

  ## Examples

      iex> delete_upload(upload)
      {:ok, %Upload{}}

      iex> delete_upload(upload)
      {:error, %Ecto.Changeset{}}

  """
  def delete_upload(%Upload{id: id, path: path} = upload) do
    with :ok <- ImageCacher.delete_from_cache(id),
    :ok <- delete_upload_file(path),
    {:ok, upload} <- Repo.delete(upload) do
      {:ok, upload}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking upload changes.

  ## Examples

      iex> change_upload(upload)
      %Ecto.Changeset{data: %Upload{}}

  """
  def change_upload(%Upload{} = upload, attrs \\ %{}) do
    Upload.changeset(upload, attrs)
  end

  defp maybe_create_user_directory(user_id) do
    case File.exists?("#{DataPath.set_data_path()}/#{user_id}") do
      false -> File.mkdir("#{DataPath.set_data_path()}/#{user_id}")
      true -> :ok
    end
  end

  defp delete_upload_file(path) do
    delete_path = UploadPathsHelper.delete_path(DataPath.set_data_path())
    full_delete_path = "#{delete_path}#{path}"
    File.rm(full_delete_path)
  end
end
