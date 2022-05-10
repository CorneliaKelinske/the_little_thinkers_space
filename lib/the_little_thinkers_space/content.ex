defmodule TheLittleThinkersSpace.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias TheLittleThinkersSpace.{Accounts, Repo}

  alias TheLittleThinkersSpace.Content.{
    DataPath,
    FileCompressor,
    FileSizeChecker,
    ImageCacher,
    Thumbnailer,
    Upload,
    UploadPathsHelper
  }

  def process_upload(content_type, filename, path, upload_params, user) do
    with :ok <- FileSizeChecker.small_enough?(path),
         {:ok, compressed_path} <- FileCompressor.compress_file(path, content_type, filename),
         {:ok, storage_path} <- store_file(filename, compressed_path, user.id),
         {:ok, thumbnail_path} <- Thumbnailer.create_thumbnail(content_type, storage_path),
         {:ok, show_path} <- UploadPathsHelper.show_path(storage_path),
         {:ok, thumbnail_show_path} <- UploadPathsHelper.thumbnail_show_path(thumbnail_path),
         {:ok, attrs} <- parse_upload_params(upload_params, show_path, thumbnail_show_path) do
      create_upload(user, attrs)
    end
  end

  defp parse_upload_params(
         %{
           "title" => title,
           "description" => description,
           "orientation" => orientation,
           "upload" => %Plug.Upload{content_type: content_type}
         },
         show_path,
         thumbnail_show_path
       ) do
    attrs = %{
      "path" => show_path,
      "thumbnail" => thumbnail_show_path,
      "title" => title,
      "description" => description,
      "orientation" => orientation,
      "file_type" => content_type
    }

    {:ok, attrs}
  end

  defp parse_upload_params(_, _, _) do
    {:error, :file_not_uploaded}
  end

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
    |> Enum.sort(&(&1.id > &2.id))
  end

  def list_little_thinker_uploads(little_thinker_id) do
    query = from u in Upload, where: u.user_id == ^little_thinker_id, select: u.id

    query
    |> Repo.all()
    |> Enum.reduce({[], []}, &ImageCacher.reduce_upload_ids/2)
    |> process_uncached_ids()
    |> Enum.sort(&(&1.id > &2.id))
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

  def store_file(filename, path, user_id) do
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

  def delete_upload(%Upload{id: id, path: path, thumbnail: thumbnail} = upload) do
    with :ok <- ImageCacher.delete_from_cache(id),
         :ok <- delete_file(path),
         :ok <- delete_file(thumbnail) do
      Repo.delete(upload)
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
    with false <- File.exists?("#{DataPath.set_data_path()}/#{user_id}"),
         :ok <- File.mkdir("#{DataPath.set_data_path()}/#{user_id}") do
      :ok
    else
      true ->
        :ok

      {:error, error} ->
        Logger.error("""
        Could not create directory with mkdir in #{inspect(__MODULE__)}, received atom: #{inspect(error)}
        """)
    end
  end

  defp delete_file(nil) do
    :ok
  end

  defp delete_file(path) do
    delete_path = UploadPathsHelper.delete_path(DataPath.set_data_path())
    full_delete_path = "#{delete_path}#{path}"
    File.rm(full_delete_path)
  end
end
