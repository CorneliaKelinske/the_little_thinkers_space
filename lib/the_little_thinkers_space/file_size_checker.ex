defmodule TheLittleThinkersSpace.FileSizeChecker do
  @moduledoc """
  This module ensures that files that are too big to be processed cannot be selcted for upload
  """

  def small_enough?(%Plug.Upload{path: path} = plug) do
    case File.stat(path) do
      {:ok, %{size: size}} ->
        if size <= 8_000_000 do
          {:ok, plug}
        else
          {:error, :file_too_big}
        end

      _ ->
        {:error, :cannot_stat_file}
    end
  end
end
