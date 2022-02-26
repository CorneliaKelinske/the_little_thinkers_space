defmodule TheLittleThinkersSpaceWeb.UploadController do
  use TheLittleThinkersSpaceWeb, :controller
  alias TheLittleThinkersSpace.{FileCompressor, Content, DataPath, UploadPathsHelper}

  alias TheLittleThinkersSpace.Content.Upload
  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    uploads = Content.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end

  def new(conn, params) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :new, user, params) do
      changeset = Content.change_upload(%Upload{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"upload" => upload}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :create, user, upload),
         upload <- FileCompressor.compress_file(upload),
         {:ok, storage_path} <- store_upload(upload, user.id),
         {:ok, show_path} <- create_show_path(storage_path),
         {:ok, attrs} <- parse_upload_params(upload, show_path),
         {:ok, upload} <- Content.create_upload(user, attrs) do
      conn
      |> put_flash(:info, "File uploaded successfully.")
      |> redirect(to: Routes.upload_path(conn, :show, upload))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Oops, something went wrong!")
        |> render("new.html", changeset: changeset)

      {:error, :file_not_uploaded} ->
        conn
        |> put_flash(:error, "Please select a file!")
        |> redirect(to: Routes.upload_path(conn, :new))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You are not allowed to do this!")
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, :no_show_path} ->
        conn
        |> put_flash(:error, "File not processed, please try again!")
        |> redirect(to: Routes.upload_path(conn, :new))
    end
  end

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)
    upload = Content.get_upload_from_cache_or_repo(id)
    render(conn, "show.html", upload: upload)
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :edit, user, id) do
      upload = Content.get_upload!(id)
      changeset = Content.change_upload(upload)
      render(conn, "edit.html", upload: upload, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "upload" => upload_params}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :update, user, %{}) do
      upload = Content.get_upload!(id)

      case Content.update_upload(upload, upload_params) do
        {:ok, upload} ->
          conn
          |> put_flash(:info, "Upload updated successfully.")
          |> redirect(to: Routes.upload_path(conn, :show, upload))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", upload: upload, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :delete, user, id) do
      upload = Content.get_upload!(id)
      {:ok, _upload} = Content.delete_upload(upload)
      delete_upload(upload)

      conn
      |> put_flash(:info, "Upload deleted successfully.")
      |> redirect(to: Routes.upload_path(conn, :index))
    end
  end

  defp store_upload(%{"upload" => %Plug.Upload{filename: filename, path: path}}, user_id) do
    maybe_create_user_directory(user_id)
    storage_path = "#{DataPath.set_data_path()}/#{user_id}/#{filename}"
    File.cp(path, "#{storage_path}")
    {:ok, storage_path}
  end

  defp delete_upload(%{path: path}) do
    delete_path = UploadPathsHelper.delete_path(DataPath.set_data_path)
    full_delete_path = "#{delete_path}#{path}"
    File.rm(full_delete_path)

  end

  defp maybe_create_user_directory(user_id) do
    case File.exists?("#{DataPath.set_data_path()}/#{user_id}") do
      false ->
        File.mkdir("#{DataPath.set_data_path()}/#{user_id}")

      true ->
        :ok
    end
  end

  defp create_show_path(storage_path) do
    UploadPathsHelper.show_path(storage_path)
  end

  defp parse_upload_params(
         %{
           "title" => title,
           "description" => description,
           "orientation" => orientation,
           "upload" => %Plug.Upload{content_type: content_type}
         },
         show_path
       ) do
    attrs = %{
      "path" => show_path,
      "title" => title,
      "description" => description,
      "orientation" => orientation,
      "file_type" => content_type
    }

    {:ok, attrs}
  end

  defp parse_upload_params(_, _) do
    {:error, :file_not_uploaded}
  end
end
