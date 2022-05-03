defmodule TheLittleThinkersSpaceWeb.CrewControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  alias TheLittleThinkersSpace.{Accounts, Repo}

  describe "index/2" do
    setup [:little_thinker, :with_crew, :admin, :user]

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

    test "lists all crews of a little thinker when the logged in user is an Admin", %{
      conn: conn,
      little_thinker: little_thinker,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.little_thinker_crew_path(conn, :index, little_thinker))

      assert html_response(conn, 200) =~ "The Crew"
    end

    test "logged in user cannot see the crew of a little thinker that they are not linked to", %{
      conn: conn,
      little_thinker: little_thinker,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_crew_path(conn, :index, little_thinker))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "a user who is linked to the little thinker as a parent can view the little thinker's crew",
         %{conn: conn, little_thinker: little_thinker, user: user} do
      Accounts.connect_users(%{
        little_thinker_id: little_thinker.id,
        user_id: user.id,
        type: "Parent"
      })

      user = Repo.preload(user, [:little_thinkers])

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_crew_path(conn, :index, little_thinker))

      assert html_response(conn, 200) =~ "The Crew"
    end

    test "a user who is linked to the little thinker but not as a parent cannot view the little thinker's crew",
         %{conn: conn, little_thinker: little_thinker, user: user} do
      Accounts.connect_users(%{
        little_thinker_id: little_thinker.id,
        user_id: user.id,
        type: "Friend"
      })

      user = Repo.preload(user, [:little_thinkers])

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_crew_path(conn, :index, little_thinker))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end
end
