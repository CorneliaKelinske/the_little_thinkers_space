defmodule TheLittleThinkersSpace.FileCompressor do
  @moduledoc """
  Compresses files uploaded by the user prior to their insertion into the database
  """

  use FFmpex.Options

  require Logger

  alias FFmpex
  alias Mogrify
  alias TheLittleThinkersSpace.{Content.Upload, FileSizeChecker}

  @valid_image_types Upload.valid_image_types()
  @valid_video_types Upload.valid_video_types()

  def compress_file(%Plug.Upload{path: path, content_type: content_type} = plug)
      when content_type in @valid_image_types do
    %{path: path} = compress_image(path)
    {:ok, %Plug.Upload{plug | path: path}}
  end

  def compress_file(
        %Plug.Upload{path: path, content_type: content_type, filename: filename} = plug
      )
      when content_type in @valid_video_types do
    renamed_path = "#{path}#{filename}"
    output_path = "#{path}_output#{filename}"

    with :ok <- File.rename(path, renamed_path),
         {:ok, _output} <- compress_video(renamed_path, output_path),
         true <- FileSizeChecker.get_file_size(output_path) < FileSizeChecker.get_file_size(renamed_path) do
      {:ok, %Plug.Upload{plug | path: output_path}}
    else
      {:error, error} ->
        Logger.error("#{inspect(__MODULE__)}: Could not convert video; #{inspect(error)}")
        {:error, :file_not_compressed}

      false -> {:ok, %Plug.Upload{plug | path: renamed_path}}
    end
  end

  def compress_file(_) do
    {:error, :invalid_file_type}
  end

  defp compress_image(path) do
    path
    |> Mogrify.open()
    |> Mogrify.resize_to_limit("1024x1024")
    |> Mogrify.quality(80)
    |> Mogrify.save()
  end

  def compress_video(renamed_path, output_path) do
    FFmpex.new_command()
    |> FFmpex.add_input_file(renamed_path)
    |> FFmpex.add_output_file(output_path)
    |> FFmpex.add_file_option(option_maxrate("2M"))
    |> FFmpex.add_file_option(option_bufsize("2M"))
    |> FFmpex.execute()
  end
end
