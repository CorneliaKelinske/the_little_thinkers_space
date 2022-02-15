defmodule TheLittleThinkersSpace.FileCompressor do
  @moduledoc """
  Compresses files uploaded by the user prior to their insertion into the database
  """
  alias Mogrify
  alias FFmpex
  use FFmpex.Options
  alias TheLittleThinkersSpace.Content.Upload
  require Logger

  @valid_image_types Upload.valid_image_types()
  @valid_video_types Upload.valid_video_types()


  def compress_file(%Plug.Upload{path: path, content_type: content_type} = plug)
        when content_type in @valid_image_types do
          %{path: path} = path
            |> Mogrify.open()
            |> Mogrify.resize_to_limit("1024x1024")
            |> Mogrify.quality(80)
            |> Mogrify.save()

    %{path: path} = open(path) |> resize_to_limit("1024x1024") |> quality(80) |> save()
    %Plug.Upload{plug | path: path}

        end

        def compress_file(%Plug.Upload{path: path, content_type: content_type, filename: file_name} = plug)
        when content_type in @video_types do

          renamed_path = path <> "#{file_name}"
          output_path = path <> "_output#{file_name}"

          command =
            FFmpex.new_command()
            |> FFmpex.add_input_file(renamed_path)
            |> FFmpex.add_output_file(output_path)
            |> FFmpex.add_file_option(option_s("1024x1024"))

            with :ok <- File.rename(path, renamed_path),
            {:ok, _output} <- FFmpex.execute(command) do
              %Plug.Upload{plug | path: output_path}
            else
              {:error, error} ->
                Logger.error("#{inspect(__MODULE__)}: Could not convert video; #{inspect(error)}")
                {:error, :file_not_compressed}

            end
        end




  

  def compress_file(_) do
    {:error, :invalid_file_type}
  end
end
