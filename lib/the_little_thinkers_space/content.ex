defmodule TheLittleThinkersSpace.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias TheLittleThinkersSpace.{Accounts, Content.Upload, ImageCacher, Repo}

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
  def delete_upload(%Upload{} = upload) do
    ImageCacher.delete_from_cache(upload.id)
    Repo.delete(upload)
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
end
