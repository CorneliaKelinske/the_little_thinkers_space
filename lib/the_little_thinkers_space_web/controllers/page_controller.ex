defmodule TheLittleThinkersSpaceWeb.PageController do
  use TheLittleThinkersSpaceWeb, :controller
  alias TheLittleThinkersSpace.{Accounts, Accounts.Profile}

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      render(conn, "home.html", lt_profile_id: lt_profile_id())
    else
      render(conn, "index.html")
    end
  end

  def home(conn, _params) do
    render(conn, "home.html", lt_profile_id: lt_profile_id())
  end

  defp lt_profile_id do
    case Accounts.get_lt_profile() do
      %Profile{id: id} -> id
      _ -> nil
    end
  end
end
