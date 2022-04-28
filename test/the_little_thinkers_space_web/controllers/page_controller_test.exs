defmodule TheLittleThinkersSpaceWeb.PageControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  setup [:user, :little_thinker]

  describe "GET /" do
    test "redirects to home if user is logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get("/")
      assert html_response(conn, 200) =~ "Hello #{user.first_name}!"
    end

    test "shows index page when user is not logged in", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Welcome to The Little Thinker&#39;s Space"
    end
  end
end
