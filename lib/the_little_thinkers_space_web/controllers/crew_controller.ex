defmodule TheLittleThinkersSpaceWeb.CrewController do
  @moduledoc """
  This controller handles the users with the role Crew in relation to The Little Thinker
  """
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.{Accounts, Accounts.Profile}

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    user = Accounts.preload_relationships(current_user)

    render(conn, "index.html", user: user)
  end
end
