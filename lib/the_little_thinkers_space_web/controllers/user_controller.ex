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
