defmodule TheLittleThinkersSpace.ShowUploadHelper do
  def show_path(path) do
    case is_binary(path) do
      true ->
        path
        |> String.replace("priv/static/", "/")
      _ ->
        nil
    end
  end
end
