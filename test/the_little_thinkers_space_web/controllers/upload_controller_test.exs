defmodule TheLittleThinkersSpaceWeb.UploadControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true

  import TheLittleThinkersSpace.ContentFixtures
  import TheLittleThinkersSpace.AccountsFixtures

  alias TheLittleThinkersSpace.{Accounts, Content, Repo}

  setup [:user, :little_thinker, :upload]

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
    test "redirects to login when user is not logged in", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_upload_path(conn, :index, little_thinker))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects logged in user to home when they are not associated with the little thinker who owns the given uploads",
         %{
           conn: conn,
           user: user,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_upload_path(conn, :index, little_thinker))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "lists all uploads of the associated little thinker when user is logged in", %{
      conn: conn,
      user: user,
      little_thinker: little_thinker
    } do
      Accounts.connect_users(%{
        little_thinker_id: little_thinker.id,
        user_id: user.id,
        type: "Friend"
      })

      user = Repo.preload(user, [:little_thinkers])

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_upload_path(conn, :index, little_thinker))

      assert html_response(conn, 200) =~ "#{little_thinker.first_name}'s uploads"
    end

    test "lists all uploads to the little thinker who owns the respective uploads", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> get(Routes.little_thinker_upload_path(conn, :index, little_thinker))

      assert html_response(conn, 200) =~ "#{little_thinker.first_name}'s uploads"
    end
  end

  describe "show upload" do
    test "redirects to login when user is not logged in", %{
      conn: conn,
      upload: upload,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects logged in user to home when they are not associated with the little thinker who owns the given upload",
         %{
           conn: conn,
           user: user,
           little_thinker: little_thinker,
           upload: upload
         } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "shows user associated with the little thinker an upload owned by the respective little thinker",
         %{
           conn: conn,
           user: user,
           little_thinker: little_thinker,
           upload: upload
         } do
      Accounts.connect_users(%{
        little_thinker_id: little_thinker.id,
        user_id: user.id,
        type: "Friend"
      })

      user = Repo.preload(user, [:little_thinkers])

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))

      assert html_response(conn, 200) =~ "some title"
    end

    test "shows the upload to the little thinker owning it", %{
      conn: conn,
      little_thinker: little_thinker,
      upload: upload
    } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> get(Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))

      assert html_response(conn, 200) =~ "some title"
    end
  end

  describe "new upload" do
    test "redirects to login when user is not logged in", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_upload_path(conn, :new, little_thinker))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "renders form when user is logged in and a Little Thinker", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> get(Routes.little_thinker_upload_path(conn, :new, little_thinker))

      assert html_response(conn, 200) =~ "New Upload"
    end

    test "redirects to upload index when user is logged in but not a Little Thinker", %{
      conn: conn,
      user: user,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_upload_path(conn, :new, little_thinker))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end

  describe "create upload" do
    test "redirects to login when user is not logged in", %{
      conn: conn,
      little_thinker: little_thinker
    } do
      conn =
        post(conn, Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @create_image_attrs
        )

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects to show when data is valid image data and user is logged in and the Little Thinker to which upload will be linked",
         %{
           conn: conn,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @create_image_attrs
        )

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) ==
               Routes.little_thinker_upload_path(conn, :show, little_thinker.id, id)

      conn = get(conn, Routes.little_thinker_upload_path(conn, :show, little_thinker.id, id))
      assert html_response(conn, 200) =~ "some title"
    end

    test "redirects to show when data is valid video data and user is logged in and the Little Thinker to which upload will be linked",
         %{
           conn: conn,
           little_thinker: little_thinker
         } do
      target_path = setup_video_file("test/support/IMG_5257.MOV")
      plug = Map.get(@create_video_attrs, :upload) |> Map.put(:path, target_path)
      new_video_attrs = Map.put(@create_video_attrs, :upload, plug)

      conn =
        conn
        |> log_in_user(little_thinker)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: new_video_attrs
        )

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) ==
               Routes.little_thinker_upload_path(conn, :show, little_thinker, id)

      conn = get(conn, Routes.little_thinker_upload_path(conn, :show, little_thinker, id))
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid and user is logged in and the corresponding Little Thinker",
         %{
           conn: conn,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @invalid_attrs
        )

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/little_thinkers/#{little_thinker.id}/uploads/new\">redirected</a>.</body></html>"
    end

    test "redirects to home when user is logged in but not a little_thinker", %{
      conn: conn,
      user: user,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @create_video_attrs
        )

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end

  describe "edit upload" do
    test "redirects to login when user is not logged in", %{
      conn: conn,
      upload: upload,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_upload_path(conn, :edit, little_thinker, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "renders form for editing chosen upload when user is logged in and the Little Thinker owning the respective upload",
         %{
           conn: conn,
           upload: upload,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> get(Routes.little_thinker_upload_path(conn, :edit, little_thinker, upload))

      assert html_response(conn, 200) =~ "Edit Upload"
    end

    test "redirects to home when user is logged in but not the corresponding Little Thinker", %{
      conn: conn,
      upload: upload,
      user: user,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.little_thinker_upload_path(conn, :edit, little_thinker, upload))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "update upload" do
    test "redirects to login when user is not logged in", %{
      conn: conn,
      upload: upload,
      little_thinker: little_thinker
    } do
      conn = get(conn, Routes.little_thinker_upload_path(conn, :update, little_thinker, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects to show when data is valid and user is logged in and the Little Thinker owning the upload",
         %{
           conn: conn,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @create_image_attrs
        )

      assert %{id: id} = redirected_params(conn)
      upload = Content.get_upload(id)

      conn =
        put(conn, Routes.little_thinker_upload_path(conn, :update, little_thinker, upload),
          upload: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.little_thinker_upload_path(conn, :show, little_thinker, upload)

      conn = get(conn, Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid and user is logged in and the Little Thinker owning the upload",
         %{
           conn: conn,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @create_image_attrs
        )

      assert %{id: id} = redirected_params(conn)
      upload = Content.get_upload(id)

      conn =
        put(conn, Routes.little_thinker_upload_path(conn, :update, little_thinker, upload),
          upload: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Upload"
    end

    test "redirects to home when user is logged in but not the corresponding little thinker", %{
      conn: conn,
      upload: upload,
      user: user,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(user)
        |> put(Routes.little_thinker_upload_path(conn, :update, little_thinker, upload),
          upload: @update_attrs
        )

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  describe "delete upload" do
    test "redirects to login when user is not logged in", %{
      conn: conn,
      upload: upload,
      little_thinker: little_thinker
    } do
      conn =
        delete(conn, Routes.little_thinker_upload_path(conn, :delete, little_thinker, upload))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "deletes chosen upload when user is logged in and the Little Thinker owning the upload",
         %{
           conn: conn,
           little_thinker: little_thinker
         } do
      conn =
        conn
        |> log_in_user(little_thinker)
        |> post(Routes.little_thinker_upload_path(conn, :create, little_thinker),
          upload: @create_image_attrs
        )

      assert %{id: id} = redirected_params(conn)
      upload = Content.get_upload(id)

      conn =
        delete(conn, Routes.little_thinker_upload_path(conn, :delete, little_thinker, upload))

      assert redirected_to(conn) ==
               Routes.little_thinker_upload_path(conn, :index, little_thinker)

      assert_error_sent 404, fn ->
        get(conn, Routes.little_thinker_upload_path(conn, :show, little_thinker, upload))
      end
    end

    test "redirects to home when user is logged in but not the corresponding Little Thinker", %{
      conn: conn,
      upload: upload,
      user: user,
      little_thinker: little_thinker
    } do
      conn =
        conn
        |> log_in_user(user)
        |> delete(Routes.little_thinker_upload_path(conn, :delete, little_thinker, upload))

      assert html_response(conn, 302) =~ "<a href=\"/home\">redirected</a>."
    end
  end

  defp setup_video_file(path) do
    target_dir = set_target_dir("priv/static/uploads/test")
    file_name = Path.basename(path)
    target_path = "#{target_dir}/#{file_name}"
    File.copy(path, target_path)
    target_path
  end

  defp set_target_dir(path) do
    case File.mkdir_p(path) do
      :ok ->
        path

      {:error, :eexist} ->
        path

      {:error, error} ->
        raise "Could not create target dir for create video test: #{inspect(error)}"
    end
  end
end
