defmodule TheLittleThinkersSpaceWeb.UploadController do
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.{
    Content,
    Content.Upload,
    FileCompressor,
    FileSizeChecker,
    UploadPathsHelper
  }

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

  def create(conn, %{"upload" => %{"upload" => upload_plug} = upload_params}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :create, user, upload_params),
         {:ok, upload_plug} <- FileSizeChecker.small_enough?(upload_plug),
         {:ok, upload_plug} <- FileCompressor.compress_file(upload_plug),
         {:ok, storage_path} <- Content.store_upload(upload_plug, user.id),
         {:ok, show_path} <- UploadPathsHelper.show_path(storage_path),
         {:ok, attrs} <- parse_upload_params(upload_params, show_path),
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

      {:error, :cannot_stat_file} ->
        conn
        |> put_flash(:error, "Could not check file size. Please try again!")
        |> redirect(to: Routes.upload_path(conn, :new))

      {:error, :file_too_big} ->
        conn
        |> put_flash(:error, "This file is too big! Try to upload a shorter video!")
        |> redirect(to: Routes.upload_path(conn, :new))

      {:error, :file_not_compressed} ->
        conn
        |> put_flash(:error, "Was not able to compress the file!")
        |> redirect(to: Routes.upload_path(conn, :new))

      {:error, :invalid_file_type} ->
        conn
        |> put_flash(:error, "Invalid file type!")
        |> redirect(to: Routes.upload_path(conn, :new))

      {:error, :file_not_saved} ->
        conn
        |> put_flash(:error, "File not saved, please try again!")
        |> redirect(to: Routes.upload_path(conn, :new))

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
      %Upload{path: path} = upload = Content.get_upload!(id)
      upload_name = Path.basename(path)
      changeset = Content.change_upload(upload)
      render(conn, "edit.html", upload: upload, upload_name: upload_name, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "upload" => upload_params}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :update, user, %{}) do
      %Upload{path: path} = upload = Content.get_upload!(id)
      upload_name = Path.basename(path)

      case Content.update_upload(upload, upload_params) do
        {:ok, upload} ->
          conn
          |> put_flash(:info, "Upload updated successfully.")
          |> redirect(to: Routes.upload_path(conn, :show, upload))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", upload: upload, changeset: changeset, upload_name: upload_name)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Upload, :delete, user, id),
         upload <- Content.get_upload!(id),
         {:ok, _upload} <- Content.delete_upload(upload) do
      conn
      |> put_flash(:info, "Upload deleted successfully.")
      |> redirect(to: Routes.upload_path(conn, :index))
    else
      nil ->
        conn
        |> put_flash(:error, "File not found!")
        |> redirect(to: Routes.upload_path(conn, :index))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You are not allowed to do this!")
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Unable to delete file!")
        |> redirect(to: Routes.upload_path(conn, :index))
    end
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
