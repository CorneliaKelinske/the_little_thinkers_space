defmodule TheLittleThinkersSpace.FileCompressor do
  import Mogrify

  def compress_file(
        %{"upload" => %Plug.Upload{path: path, content_type: content_type} = plug} = upload
      )
      when content_type in ["image/jpeg", "image/jpg", "image/png"] do
    %{path: path} = open(path) |> resize_to_limit("800x800") |> quality(70) |> save()
    upload = %{upload | "upload" => %Plug.Upload{plug | path: path}}
    upload
  end

  def compress_file(upload) do
    upload
  end
end
