defmodule TheLittleThinkersSpaceWeb.PageController do
  use TheLittleThinkersSpaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
