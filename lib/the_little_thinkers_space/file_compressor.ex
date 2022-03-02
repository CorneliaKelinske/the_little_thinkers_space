defmodule TheLittleThinkersSpace.FileCompressor do
  @moduledoc """
  Compresses files uploaded by the user prior to their insertion into the database
  """
  import Mogrify

  def compress_file(%Plug.Upload{path: path, content_type: content_type} = plug)
      when content_type in ["image/jpeg", "image/jpg", "image/png"] do
    %{path: path} = open(path) |> resize_to_limit("1024x1024") |> quality(80) |> save()
    %Plug.Upload{plug | path: path}
  end

  def compress_file(upload) do
    upload
  end
end
