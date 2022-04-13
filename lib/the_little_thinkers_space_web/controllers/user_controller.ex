defmodule TheLittleThinkersSpaceWeb.UserController do
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.Accounts
  alias TheLittleThinkersSpace.Accounts.User

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(User, :index, current_user) do
      users = Accounts.list_users()
      render(conn, "index.html", users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    with %User{} = user <- Accounts.get_user(id),
         :ok <- Bodyguard.permit(User, :show, current_user, user) do
      render(conn, "show.html", user: user)
    end
  end

  def edit(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    user = Accounts.get_user!(id)

    with :ok <- Bodyguard.permit(User, :edit, current_user, user) do
      changeset = Accounts.change_user(user)
      render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    current_user = conn.assigns.current_user
    user = Accounts.get_user!(id)

    with :ok <- Bodyguard.permit(User, :edit, current_user, user) do
      case Accounts.update_user(user, user_params) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: Routes.user_path(conn, :show, user))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", user: user, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    user = Accounts.get_user(id)

    with :ok <- Bodyguard.permit(User, :delete, current_user, user) do
      {:ok, _user} = Accounts.delete_user(user)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: Routes.user_path(conn, :index))
    end
  end
end
