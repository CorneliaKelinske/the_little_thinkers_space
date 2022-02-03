defmodule TheLittleThinkersSpaceWeb.FallbackController do
  use TheLittleThinkersSpaceWeb, :controller

  def call(conn, nil) do
    conn
    |> put_view(TheLittleThinkersSpaceWeb.ErrorView)
    |> render("404.html")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_flash(:error, "You are not allowed to do this!")
    |> redirect(to: Routes.page_path(conn, :home))
  end
end
