defmodule TheLittleThinkersSpace.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias TheLittleThinkersSpace.Repo
  alias TheLittleThinkersSpace.Content.Upload
  alias TheLittleThinkersSpace.Accounts

  @doc """
  Returns the list of uploads.

  ## Examples

      iex> list_uploads()
      [%Upload{}, ...]

  """
  def list_uploads do
    query = from u in "uploads",
    select: u.id

    Repo.all(query)
    |> Enum.reduce([], fn x, acc -> [get_upload_from_cache_or_repo(x) | acc] end)
    |> Enum.reverse
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
    ConCache.delete(:upload_cache, upload.id)
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

  def get_upload_from_cache_or_repo(id) when is_integer(id) do
    case ConCache.get(:upload_cache, id) do
      nil -> upload = Repo.get!(Upload, id)
             ConCache.put(:upload_cache, id, upload)
             upload
      upload -> upload
    end
  end
end
