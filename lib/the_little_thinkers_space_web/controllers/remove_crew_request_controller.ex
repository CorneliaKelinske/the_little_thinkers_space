defmodule TheLittleThinkersSpaceWeb.RemoveCrewRequestController do
  use TheLittleThinkersSpaceWeb, :controller
  alias TheLittleThinkersSpace.Email.{EmailBuilder, RemoveCrewRequest}
  alias TheLittleThinkersSpace.Mailer

  def new(conn, _params) do
    render(conn, "new.html", changeset: RemoveCrewRequest.changeset(%{}))
  end

  def create(conn, %{"remove_crew_request_content" => message_params}) do
    changeset = RemoveCrewRequest.changeset(message_params)

    with {:ok, content} <- Ecto.Changeset.apply_action(changeset, :insert),
         %Swoosh.Email{} = message <- EmailBuilder.create_remove_crew_request(content),
         {:ok, _map} <- Mailer.deliver(message) do
      conn
      |> put_flash(:info, "Your request has been sent successfully")
      |> redirect(to: Routes.page_path(conn, :home))
    else
      # Failed changeset validation
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Request not sent. Please try again!")
        |> render("new.html", changeset: changeset)

      # Anything else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.contact_path(conn, :new))
    end
  end
end
