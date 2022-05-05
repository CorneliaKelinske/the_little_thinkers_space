defmodule TheLittleThinkersSpaceWeb.AddCrewRequestControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  setup [:user]

  @valid_params %{
    from_email: "tester@test.com",
    little_thinker_first_name: "Bubi",
    little_thinker_last_name: "Kopf",
    new_crew_first_name: "Bumba",
    new_crew_last_name: "Oyeah",
    new_crew_email: "bumba@example.com",
    message: "Let's jump into the news!"
  }

  @invalid_params %{
    from_email: "tester@test.com",
    little_thinker_first_name: nil,
    little_thinker_last_name: "Kopf",
    new_crew_first_name: "Bumba",
    new_crew_last_name: "Oyeah",
    new_crew_email: "bumba@example.com",
    message: "Let's jump into the news!"
  }

  describe "new" do
    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.add_crew_request_path(conn, :new))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end
  end

  test "renders the request form when user is logged in", %{conn: conn, user: user} do
    conn =
      conn
      |> log_in_user(user)
      |> get(Routes.add_crew_request_path(conn, :new))

    assert html_response(conn, 200) =~ "Add a new crew member"
  end

  describe "create" do
    test "redirects to login if user is not logged in", %{conn: conn} do
      conn =
        post(conn, Routes.add_crew_request_path(conn, :create),
          add_crew_request_content: @valid_params
        )

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "delivers request and redirects to home when valid params are provided by the logged in user",
         %{
           conn: conn,
           user: user
         } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.add_crew_request_path(conn, :create),
          add_crew_request_content: @valid_params
        )

      assert redirected_to(conn) == Routes.page_path(conn, :home)
    end

    test "renders errors when invalid params are provided by the logged in user", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.add_crew_request_path(conn, :create),
          add_crew_request_content: @invalid_params
        )

      assert [
               little_thinker_first_name: {"This box must not be empty!", [validation: :required]}
             ] == conn.assigns.changeset.errors

      assert html_response(conn, 200) =~ "Add a new crew member"
    end
  end
end
