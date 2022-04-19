defmodule TheLittleThinkersSpaceWeb.CrewControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase
  import TheLittleThinkersSpace.AccountsFixtures


  describe "index/2" do
    setup [:user, :with_crew]

    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.crew_path(conn, :index))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "lists all crews of a user when user is logged in", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.crew_path(conn, :index))

      assert html_response(conn, 200) =~ "The Crew"
    end
  end
end
