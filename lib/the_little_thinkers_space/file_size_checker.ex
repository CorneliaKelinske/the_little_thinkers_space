defmodule TheLittleThinkersSpace.FileSizeChecker do
  @moduledoc """
  This module ensures that files that are too big to be processed cannot be selcted for upload
  """

  def is_small_enough?(%Plug.Upload{path: path} = plug) do
    {:ok, %{size: size}} = File.stat(path)
    if size <= 8000000 do
      {:ok, plug}
    else
      {:error, :file_too_big}
    end
  end
end
