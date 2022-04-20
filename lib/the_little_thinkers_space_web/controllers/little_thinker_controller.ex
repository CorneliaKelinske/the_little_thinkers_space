defmodule TheLittleThinkersSpaceWeb.LittleThinkerController do
  @moduledoc """
  This controller handles the Little Thinkers whose content a given user is able to view
  """
  use TheLittleThinkersSpaceWeb, :controller

  alias TheLittleThinkersSpace.Accounts

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    user = Accounts.preload_relationships(current_user)

    render(conn, "index.html", user: user)
  end
end
