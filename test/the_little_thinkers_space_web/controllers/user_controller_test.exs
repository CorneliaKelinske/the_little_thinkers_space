defmodule TheLittleThinkersSpaceWeb.UserControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase

  import TheLittleThinkersSpace.AccountsFixtures

  setup do
    %{user: user_fixture(), admin: admin_fixture()}
  end

  describe "index" do
    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "lists all users when user is logged in and Admin", %{conn: conn, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.user_path(conn, :index))

      assert html_response(conn, 200) =~ "Listing Users"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_path(conn, :index))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "show user" do
    test "redirects to login when user is not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "shows user info when user is logged in and Admin", %{
      conn: conn,
      admin: admin,
      user: user
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.user_path(conn, :show, user))

      assert html_response(conn, 200) =~ "Show User"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_path(conn, :show, user))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "edit/2" do
    test "redirects to login when user is not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "shows edit user form when user is logged in and Admin", %{
      conn: conn,
      admin: admin,
      user: user
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Edit User"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_path(conn, :edit, user))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "delete user" do
    test "redirects to login if user performing doing the deleting is not logged in", %{
      conn: conn,
      user: user
    } do
      conn = get(conn, Routes.user_path(conn, :delete, user))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "deletes chosen user if user doing the deleting is logged in", %{
      conn: conn,
      user: user,
      admin: admin
    } do
      conn = conn |> log_in_user(admin) |> delete(Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)
    end

    test "once a user has been deleted, it can no longer be viewed via the show function", %{
      conn: conn,
      user: user,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> delete(Routes.user_path(conn, :delete, user))
        |> get(Routes.user_path(conn, :show, user))

      assert html_response(conn, 200) =~ "Not Found"
    end
  end
end
