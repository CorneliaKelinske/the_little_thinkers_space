defmodule TheLittleThinkersSpaceWeb.CrewControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  describe "index/2" do
    setup [:little_thinker, :with_crew]

    test "redirects to login when little_thinker is not logged in", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_crew_path(conn, :index, little_thinker))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "lists all crews of a little_thinker when little_thinker is logged in", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> get(Routes.little_thinker_crew_path(conn, :index, little_thinker))

      assert html_response(conn, 200) =~ "The Crew"
    end
  end
end
