defmodule TheLittleThinkersSpace.ShowUploadHelper do
  def show_path(path) do
    case is_binary(path) do
      true ->
        show_path =
          path
          |> String.replace("priv/static/", "/")
          |> String.replace("//", "/")

        {:ok, show_path}

      _ ->
        {:error, :no_show_path}
    end
  end
end
