defmodule TheLittleThinkersSpaceWeb.PageController do
  use TheLittleThinkersSpaceWeb, :controller

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      render(conn, "home.html")
    else
      render(conn, "index.html")
    end
  end

  def home(conn, _params) do
    render(conn, "home.html")
  end
end
