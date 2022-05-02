defmodule TheLittleThinkersSpaceWeb.ProfileController do
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.Accounts
  alias TheLittleThinkersSpace.Accounts.Profile

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(Profile, :index, current_user) do
      profiles = Accounts.list_profiles()
      render(conn, "index.html", profiles: profiles)
    end
  end

  def new(conn, _params) do
    current_user = conn.assigns.current_user
    user_id = current_user.id

    case Accounts.get_user_profile(user_id) do
      %Profile{} = profile ->
        redirect(conn, to: Routes.profile_path(conn, :show, profile))

      _ ->
        changeset = Accounts.change_profile(%Profile{})
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"profile" => profile_params}) do
    id = conn.assigns.current_user.id

    profile_params
    |> Map.merge(%{"user_id" => id})
    |> Accounts.create_profile()
    |> case do
      {:ok, profile} ->
        conn
        |> put_flash(:info, "Profile created successfully.")
        |> redirect(to: Routes.profile_path(conn, :show, profile))

      {:error, %Ecto.Changeset{errors: [user_id: _]}} ->
        conn
        |> put_flash(:error, "You already have a profile")
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    profile = Accounts.get_profile!(id)

    with :ok <- Bodyguard.permit(Profile, :show, current_user, profile) do
      render(conn, "show.html", profile: profile)
    end
  end

  def edit(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    profile = Accounts.get_profile!(id)

    with :ok <- Bodyguard.permit(Profile, :edit, current_user, profile) do
      changeset = Accounts.change_profile(profile)
      render(conn, "edit.html", profile: profile, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "profile" => profile_params}) do
    current_user = conn.assigns.current_user
    profile = Accounts.get_profile!(id)

    with :ok <- Bodyguard.permit(Profile, :edit, current_user, profile) do
      case Accounts.update_profile(profile, profile_params) do
        {:ok, profile} ->
          conn
          |> put_flash(:info, "Profile updated successfully.")
          |> redirect(to: Routes.profile_path(conn, :show, profile))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", profile: profile, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    profile = Accounts.get_profile!(id)

    with :ok <- Bodyguard.permit(Profile, :delete, current_user, profile) do
      {:ok, _profile} = Accounts.delete_profile(profile)

      conn
      |> put_flash(:info, "Profile deleted successfully.")
      |> redirect(to: Routes.profile_path(conn, :new))
    end
  end
end
