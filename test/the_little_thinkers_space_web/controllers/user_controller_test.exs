defmodule TheLittleThinkersSpaceWeb.UserControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase

  import TheLittleThinkersSpace.AccountsFixtures

  @update_attrs %{first_name: "updated first_name"}
  @invalid_attrs %{first_name: nil}

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
      conn = get(conn, Routes.user_path(conn, :edit, user))

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

      assert html_response(conn, 200) =~ "Update User"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_path(conn, :edit, user))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "update/2" do
    test "redirects to login when user is not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :update, user))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "updates user and redirects to show page when data is valid, user is logged in and Admin",
         %{conn: conn, admin: admin, user: user} do
      conn =
        conn
        |> log_in_user(admin)
        |> put(Routes.user_path(conn, :update, user), user: @update_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "updated first_name"
    end

    test "renders errors when data is invalid and logged in Admin attempts to update user", %{
      conn: conn,
      admin: admin,
      user: user
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> put(Routes.user_path(conn, :update, user), user: @invalid_attrs)

      assert html_response(conn, 200) =~ "Update User"
    end

    test "does not allow Admin to update user to duplicate first and last name combination", %{
      conn: conn,
      admin: admin,
      user: user
    } do
      duplicate_attrs = %{first_name: admin.first_name, last_name: admin.last_name}

      conn =
        conn
        |> log_in_user(admin)
        |> put(Routes.user_path(conn, :update, user), user: duplicate_attrs)

      assert html_response(conn, 200) =~ "Update User"
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
