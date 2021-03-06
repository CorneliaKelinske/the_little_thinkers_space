defmodule TheLittleThinkersSpaceWeb.LittleThinkerController do
  @moduledoc """
  This controller handles the Little Thinkers whose content a given user is able to view
  """
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.{Accounts, Accounts.Relationship, Accounts.User}

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    render(conn, "index.html", user: user)
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    %User{} = little_thinker = Accounts.get_user(id)
    relationship_type = Accounts.get_relationship_type(little_thinker.id, user.id)
    conn = conn |> assign(:relationship_type, relationship_type)

    with :ok <- Bodyguard.permit(Relationship, :show, user, little_thinker) do
      render(conn, "show.html", little_thinker: little_thinker)
    end
  end
end
