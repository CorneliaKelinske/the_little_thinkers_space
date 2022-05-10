defmodule TheLittleThinkersSpaceWeb.UploadController do
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.{Accounts, Content, Content.Upload}

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, %{"little_thinker_id" => little_thinker_id}) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)

    uploads = Content.list_little_thinker_uploads(little_thinker_id)

    with :ok <- Bodyguard.permit(Upload, :index, user, {uploads, little_thinker_id}) do
      render(conn, "index.html", little_thinker: little_thinker, uploads: uploads)
    end
  end

  def new(conn, %{"little_thinker_id" => little_thinker_id}) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)

    with :ok <- Bodyguard.permit(Upload, :new, user, little_thinker_id) do
      changeset = Content.change_upload(%Upload{})
      render(conn, "new.html", changeset: changeset, little_thinker: little_thinker)
    end
  end

  def create(conn, %{
        "upload" =>
          %{"upload" => %Plug.Upload{content_type: content_type, filename: filename, path: path}} =
            upload_params,
        "little_thinker_id" => little_thinker_id
      }) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)

    with :ok <- Bodyguard.permit(Upload, :create, user, {upload_params, little_thinker_id}),
         {:ok, upload} <-
           Content.process_upload(content_type, filename, path, upload_params, user) do
      conn
      |> put_flash(:info, "File uploaded successfully.")
      |> redirect(to: Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Oops, something went wrong!")
        |> render("new.html", changeset: changeset, little_thinker: little_thinker)

      {:error, :file_not_uploaded} ->
        conn
        |> put_flash(:error, "Please select a file!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You are not allowed to do this!")
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, :cannot_stat_file} ->
        conn
        |> put_flash(:error, "Could not check file size. Please try again!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :file_too_big} ->
        conn
        |> put_flash(:error, "This file is too big! Try to upload a shorter video!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :file_not_compressed} ->
        conn
        |> put_flash(:error, "Was not able to compress the file!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :invalid_file_type} ->
        conn
        |> put_flash(:error, "Invalid file type!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :file_not_saved} ->
        conn
        |> put_flash(:error, "File not saved, please try again!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :no_show_path} ->
        conn
        |> put_flash(:error, "File not processed, please try again!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :no_thumbnail_show_path} ->
        conn
        |> put_flash(:error, "Thumbnail not processed, please try again!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))

      {:error, :no_thumbnail_path} ->
        conn
        |> put_flash(:error, "Thumbnail could not be created, please try again!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :new, little_thinker))
    end
  end

  def show(conn, %{"id" => id, "little_thinker_id" => little_thinker_id}) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)
    id = String.to_integer(id)

    upload = Content.get_upload_from_cache_or_repo(id)

    with :ok <- Bodyguard.permit(Upload, :show, user, upload) do
      render(conn, "show.html", upload: upload, little_thinker: little_thinker)
    end
  end

  def edit(conn, %{"id" => id, "little_thinker_id" => little_thinker_id}) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)
    %Upload{path: path} = upload = Content.get_upload!(id)

    with :ok <- Bodyguard.permit(Upload, :edit, user, upload) do
      upload_name = Path.basename(path)
      changeset = Content.change_upload(upload)

      render(conn, "edit.html",
        upload: upload,
        upload_name: upload_name,
        changeset: changeset,
        little_thinker: little_thinker
      )
    end
  end

  def update(conn, %{
        "id" => id,
        "upload" => upload_params,
        "little_thinker_id" => little_thinker_id
      }) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)
    %Upload{path: path} = upload = Content.get_upload!(id)

    with :ok <- Bodyguard.permit(Upload, :update, user, upload) do
      upload_name = Path.basename(path)

      case Content.update_upload(upload, upload_params) do
        {:ok, upload} ->
          conn
          |> put_flash(:info, "Upload updated successfully.")
          |> redirect(to: Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            upload: upload,
            changeset: changeset,
            upload_name: upload_name,
            little_thinker: little_thinker
          )
      end
    end
  end

  def delete(conn, %{"id" => id, "little_thinker_id" => little_thinker_id}) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)

    with upload <- Content.get_upload!(id),
         :ok <- Bodyguard.permit(Upload, :delete, user, upload),
         {:ok, _upload} <- Content.delete_upload(upload) do
      conn
      |> put_flash(:info, "Upload deleted successfully.")
      |> redirect(to: Routes.little_thinker_upload_path(conn, :index, little_thinker))
    else
      nil ->
        conn
        |> put_flash(:error, "File not found!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :index, little_thinker))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You are not allowed to do this!")
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Unable to remove database entry!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :index, little_thinker))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Unable to delete file!")
        |> redirect(to: Routes.little_thinker_upload_path(conn, :index, little_thinker))
    end
  end
end
