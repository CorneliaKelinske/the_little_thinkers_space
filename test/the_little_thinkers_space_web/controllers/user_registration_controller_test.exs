defmodule TheLittleThinkersSpaceWeb.UserRegistrationControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true

  import TheLittleThinkersSpace.AccountsFixtures

  setup [:user, :admin, :little_thinker]

  describe "GET /users/register" do
    test "renders registration page if user is logged in and Admin", %{conn: conn, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.user_registration_path(conn, :new))

      response = html_response(conn, 200)
      assert response =~ "Register a new user"
    end

    test "redirects to log in page if user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/users/log_in"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_registration_path(conn, :new))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account when user registering the new user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      email = unique_user_email()

      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(email: email)
        })

      assert redirected_to(conn) == "/users/admin"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/home")
      response = html_response(conn, 200)

      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "render errors for invalid data if user registering the new user is logged in and Admin",
         %{
           conn: conn,
           admin: admin
         } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Register a new user"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      email = unique_user_email()

      conn
      |> log_in_user(user)
      |> post(Routes.user_registration_path(conn, :create), %{
        "user" => valid_user_attributes(email: email)
      })
    end
  end
end
