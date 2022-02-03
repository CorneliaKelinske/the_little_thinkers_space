defmodule TheLittleThinkersSpaceWeb.UserRegistrationController do
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.Accounts
  alias TheLittleThinkersSpace.Accounts.User

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def new(conn, _params) do
    current_user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(User, :new, current_user) do
      changeset = Accounts.change_user_registration(%User{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    current_user = conn.assigns.current_user

    with :ok <- Bodyguard.permit(User, :create, current_user, user_params) do
      case Accounts.register_user(user_params) do
        {:ok, user} ->
          {:ok, _} =
            Accounts.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(conn, :edit, &1)
            )

          conn
          |> put_flash(:info, "#{user.name} created successfully!")
          |> redirect(to: Routes.user_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end
end
