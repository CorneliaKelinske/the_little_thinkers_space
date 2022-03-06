defmodule TheLittleThinkersSpace.ImageCacher do
  @moduledoc """
  Checks if upload can be retrieved from the cache and, if not,
  inserts upload into the cache if it is an image file. Videos are not
  cached at this point due to smaller server capacity in production.
  """

  import Ecto.Query, warn: false
  alias TheLittleThinkersSpace.Content.Upload

  def get_upload_from_cache_or_repo(id, fun) when is_integer(id) do
    with nil <- ConCache.get(:upload_cache, id) do
      id
      |> fun.()
      |> maybe_save_to_cache()
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

  def maybe_save_to_cache(%Upload{id: id, file_type: file_type} = upload) do
    if file_type in Upload.valid_image_types() do
      ConCache.put(:upload_cache, id, upload)
    end

    upload
  end
end
