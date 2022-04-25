defmodule TheLittleThinkersSpaceWeb.CrewController do
  @moduledoc """
  This controller handles the users with the role Crew in relation to The Little Thinker
  """
  use TheLittleThinkersSpaceWeb, :controller

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    render(conn, "index.html", user: user)
  end
end
