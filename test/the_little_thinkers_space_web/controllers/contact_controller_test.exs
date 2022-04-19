defmodule TheLittleThinkersSpaceWeb.ContactControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true

  @valid_params %{
    from_email: "tester@test.com",
    name: "testy McTestface",
    subject: "Testing, testing",
    message: "Hello, this is a test"
  }

  @invalid_params %{
    from_email: "tester@test.com",
    name: nil,
    subject: "Testing, testing",
    message: "Hello, this is a test"
  }

  test "new renders form", %{conn: conn} do
    conn = get(conn, Routes.contact_path(conn, :new))
    assert html_response(conn, 200) =~ "Contact The Little Thinker's Adult"
  end

  describe "create" do
    test "delivers email and redirects to index when when valid params are provided", %{
      conn: conn
    } do
      {captcha_text, _captcha_image} = ExRoboCop.create_captcha()
      id = ExRoboCop.create_form_id(captcha_text)
      content = Map.merge(@valid_params, %{not_a_robot: captcha_text, form_id: id})

      conn = post(conn, Routes.contact_path(conn, :create), content: content)

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "renders errors when params provided are invalid", %{conn: conn} do
      {captcha_text, _captcha_image} = ExRoboCop.create_captcha()
      id = ExRoboCop.create_form_id(captcha_text)
      content = Map.merge(@invalid_params, %{not_a_robot: captcha_text, form_id: id})
      conn = post(conn, Routes.contact_path(conn, :create), content: content)
      assert html_response(conn, 200) =~ "Contact The Little Thinker's Adult"
    end

    test "renders contact page again, if captcha answer entered is incorrect ", %{
      conn: conn
    } do
      {captcha_text, _captcha_image} = ExRoboCop.create_captcha()
      id = ExRoboCop.create_form_id(captcha_text)
      content = Map.merge(@valid_params, %{not_a_robot: "some random text", form_id: id})
      conn = post(conn, Routes.contact_path(conn, :create), content: content)

      assert html_response(conn, 200) =~ "Contact The Little Thinker's Adult"
    end
  end
end
