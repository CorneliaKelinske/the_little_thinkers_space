defmodule TheLittleThinkersSpaceWeb.LittleThinkerControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  describe "index/2" do
    setup [:user, :with_little_thinker]

    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.crew_path(conn, :index))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "lists all little thinkers a user is following when user is logged in", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_path(conn, :index))

      assert html_response(conn, 200) =~ "Little Thinkers I Follow"
    end
  end
end
