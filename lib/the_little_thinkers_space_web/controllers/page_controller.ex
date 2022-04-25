defmodule TheLittleThinkersSpaceWeb.PageController do
  use TheLittleThinkersSpaceWeb, :controller
  alias TheLittleThinkersSpace.{Accounts, Accounts.Profile}

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      render(conn, "home.html", lt_profile_id: lt_profile_id(), little_thinker: Accounts.get_lt())
    else
      render(conn, "index.html")
    end
  end

  def home(conn, _params) do
    current_user = conn.assigns.current_user
    render(conn, "home.html", lt_profile_id: lt_profile_id(), little_thinker: Accounts.get_lt())
  end

  defp lt_profile_id do
    case Accounts.get_lt_profile() do
      %Profile{id: id} -> id
      _ -> nil
    end
  end
end
