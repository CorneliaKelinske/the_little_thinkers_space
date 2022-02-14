defmodule TheLittleThinkersSpace.ImageCacher do
  @moduledoc """
  Checks if upload can be retrieved from the cache and, if not,
  inserts upload into the cache if it is an image file. Videos are not
  cached at this point due to smaller server capacity in production.
  """

  import Ecto.Query, warn: false
  alias TheLittleThinkersSpace.Repo
  alias TheLittleThinkersSpace.Content.Upload

  def get_upload_from_cache_or_repo(id) when is_integer(id) do
    case ConCache.get(:upload_cache, id) do
      nil ->
        upload = Repo.get!(Upload, id)
        maybe_save_to_cache(id, upload)
        upload

      upload ->
        upload
    end
  end

  def delete_from_cache(upload_id) do
    ConCache.delete(:upload_cache, upload_id)
  end

  def reduce_upload_ids(upload_id, {uploads, uncached_ids}) do
    case ConCache.get(:upload_cache, upload_id) do
      nil -> {uploads, [upload_id | uncached_ids]}
      %Upload{} = upload -> {[upload | uploads], uncached_ids}
    end
  end

  def process_uncached_ids({uploads, uncached_ids}) do
    from(u in Upload, where: u.id in ^uncached_ids)
    |> Repo.all()
    |> Enum.map(&maybe_save_to_cache/1)
    |> Kernel.++(uploads)
  end

  defp maybe_save_to_cache(id, %Upload{file_type: file_type} = upload) do
    if file_type in Upload.valid_image_types() do
      IO.puts("SAVED TO CACHE")
      ConCache.put(:upload_cache, id, upload)
    end
  end

  defp maybe_save_to_cache(%Upload{id: id} = upload) do
    maybe_save_to_cache(id, upload)
    upload
  end
end
