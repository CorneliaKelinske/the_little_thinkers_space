defmodule TheLittleThinkersSpaceWeb.UploadControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase

  import TheLittleThinkersSpace.ContentFixtures
  import TheLittleThinkersSpace.AccountsFixtures

  alias TheLittleThinkersSpace.Content

  setup do
    %{user: user_fixture(), admin: admin_fixture()}
  end

  @create_image_attrs %{
    description: "some description",
    file: "some file",
    file_type: "image/jpg",
    title: "some title",
    orientation: "Landscape",
    upload: %Plug.Upload{
      filename: "Lifting.jpg",
      path: "test/support/Lifting.jpg",
      content_type: "image/jpg"
    }
  }

  @create_video_attrs %{
    description: "some description",
    file: "some file",
    file_type: "video/quicktime",
    title: "some title",
    orientation: "Landscape",
    upload: %Plug.Upload{
      filename: "IMG_5257.MOV",
      path: "test/support/IMG_5257.MOV",
      content_type: "video/quicktime"
    }
  }

  @update_attrs %{
    description: "some description",
    file: "some file",
    file_type: "image/jpg",
    title: "some title",
    orientation: "Landscape",
    upload: %Plug.Upload{
      filename: "IMG_5248.jpg",
      path: "test/support/IMG_5248.jpg",
      content_type: "image/jpg"
    }
  }

  @invalid_attrs %{
    description: nil,
    file: nil,
    file_type: nil,
    title: nil,
    orientation: "Landscape",
    upload: %Plug.Upload{
      filename: "Lifting.jpg",
      path: "test/support/Lifting.jpg",
      content_type: nil
    }
  }

  describe "index" do
    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.upload_path(conn, :index))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "lists all uploads when user is logged in", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.upload_path(conn, :index))

      assert html_response(conn, 200) =~ "Ulrik's uploads"
    end
  end

  describe "new upload" do
    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.upload_path(conn, :new))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "renders form when user is logged in and Admin", %{conn: conn, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.upload_path(conn, :new))

      assert html_response(conn, 200) =~ "New Upload"
    end

    test "redirects to upload index when user is logged in but not an Admin", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.upload_path(conn, :new))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end

  describe "create upload" do
    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = post(conn, Routes.upload_path(conn, :create), upload: @create_image_attrs)

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects to show when data is valid image data and user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.upload_path(conn, :create), upload: @create_image_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.upload_path(conn, :show, id)

      conn = get(conn, Routes.upload_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some title"
    end

    test "redirects to show when data is valid video data and user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.upload_path(conn, :create), upload: @create_video_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.upload_path(conn, :show, id)

      conn = get(conn, Routes.upload_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid and user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.upload_path(conn, :create), upload: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Upload"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.upload_path(conn, :create), upload: @create_video_attrs)

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end

  describe "edit upload" do
    setup [:create_upload]

    test "redirects to login when user is not logged in", %{conn: conn, upload: upload} do
      conn = get(conn, Routes.upload_path(conn, :edit, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "renders form for editing chosen upload when user is logged in and Admin", %{
      conn: conn,
      upload: upload,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.upload_path(conn, :edit, upload))

      assert html_response(conn, 200) =~ "Edit Upload"
    end

    test "redirects to home when user is logged in but no Admin", %{
      conn: conn,
      upload: upload,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.upload_path(conn, :edit, upload))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "update upload" do
    setup [:create_upload]

    test "redirects to login when user is not logged in", %{conn: conn, upload: upload} do
      conn = get(conn, Routes.upload_path(conn, :update, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects when data is valid and user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.upload_path(conn, :create), upload: @create_image_attrs)

      assert %{id: id} = redirected_params(conn)
      upload = Content.get_upload(id)
      conn = put(conn, Routes.upload_path(conn, :update, upload), upload: @update_attrs)

      assert redirected_to(conn) == Routes.upload_path(conn, :show, upload)

      conn = get(conn, Routes.upload_path(conn, :show, upload))
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid and user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.upload_path(conn, :create), upload: @create_image_attrs)

      assert %{id: id} = redirected_params(conn)
      upload = Content.get_upload(id)
      conn = put(conn, Routes.upload_path(conn, :update, upload), upload: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Upload"
    end

    test "redirects to home when user is logged in but no Admin", %{
      conn: conn,
      upload: upload,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> put(Routes.upload_path(conn, :update, upload), upload: @update_attrs)

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "delete upload" do
    setup [:create_upload]

    test "redirects to login when user is not logged in", %{conn: conn, upload: upload} do
      conn = delete(conn, Routes.upload_path(conn, :delete, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "deletes chosen upload when user is logged in and Admin", %{
      conn: conn,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(Routes.upload_path(conn, :create), upload: @create_image_attrs)

      assert %{id: id} = redirected_params(conn)
      upload = Content.get_upload(id)
      conn = delete(conn, Routes.upload_path(conn, :delete, upload))

      assert redirected_to(conn) == Routes.upload_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.upload_path(conn, :show, upload))
      end
    end

    test "redirects to home when user is logged in but no Admin", %{
      conn: conn,
      upload: upload,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> delete(Routes.upload_path(conn, :delete, upload))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  defp create_upload(_) do
    upload = upload_fixture()
    %{upload: upload}
  end
end
