defmodule TheLittleThinkersSpaceWeb.LittleThinkerControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  alias TheLittleThinkersSpace.{Accounts, Repo}

  describe "index/2" do
    setup [:user, :with_little_thinker]

    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.little_thinker_path(conn, :index))

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

  describe "show/2" do
    setup [:user, :little_thinker, :admin]

    test "redirects to login when user is not logged in", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_path(conn, :show, little_thinker))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "renders the little thinker show page if user is logged in and admin", %{
      conn: conn,
      little_thinker: little_thinker,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.little_thinker_path(conn, :show, little_thinker))

      assert html_response(conn, 200) =~ "Welcome to #{little_thinker.first_name}'s Space!"
    end

    test "renders the little thinker show page to the little thinker owning the page", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> get(Routes.little_thinker_path(conn, :show, little_thinker))

      assert html_response(conn, 200) =~ "Welcome to #{little_thinker.first_name}'s Space!"
    end

    test "renders the little thinker show page to a logged in user linked to the respective little thinker",
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
        |> get(Routes.little_thinker_path(conn, :show, little_thinker))

      assert html_response(conn, 200) =~ "Welcome to #{little_thinker.first_name}'s Space!"
    end

    test "redirects to home when logged in user is not linked to the respective little thinker",
         %{conn: conn, little_thinker: little_thinker, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_path(conn, :show, little_thinker))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end
end
