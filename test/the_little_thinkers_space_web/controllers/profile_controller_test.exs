defmodule TheLittleThinkersSpaceWeb.ProfileControllerTest do
  use TheLittleThinkersSpaceWeb.ConnCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures
  alias TheLittleThinkersSpace.Accounts
  alias TheLittleThinkersSpace.Accounts.Profile

  setup [:user, :admin]

  @create_attrs %{
    animal: "some animal",
    belongs_to_lt: false,
    birthday: ~D[2021-10-18],
    book: "some book",
    color: "some color",
    first_name: "some first_name",
    food: "some food",
    future: "some future",
    joke: "some joke",
    last_name: "some last_name",
    movie: "some movie",
    nickname: "some nickname",
    song: "some song",
    superhero: "some superhero"
  }
  @update_attrs %{
    animal: "some updated animal",
    belongs_to_lt: false,
    birthday: ~D[2021-10-19],
    book: "some updated book",
    color: "some updated color",
    first_name: "some updated first_name",
    food: "some updated food",
    future: "some updated future",
    joke: "some updated joke",
    last_name: "some updated last_name",
    movie: "some updated movie",
    nickname: "some updated nickname",
    song: "some updated song",
    superhero: "some updated superhero"
  }
  @invalid_attrs %{
    animal: nil,
    belongs_to_lt: nil,
    birthday: nil,
    book: nil,
    color: nil,
    first_name: nil,
    food: nil,
    future: nil,
    joke: nil,
    last_name: nil,
    movie: nil,
    nickname: nil,
    song: nil,
    superhero: nil
  }

  describe "index" do
    test "lists all profiles when user is logged in and admin", %{conn: conn, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.profile_path(conn, :index))

      assert html_response(conn, 200) =~ "The Crew"
    end

    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.profile_path(conn, :index))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "redirects to home when user is logged in but no Admin", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.profile_path(conn, :index))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end
  end

  describe "new profile" do
    test "renders form when user is logged in", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.profile_path(conn, :new))

      assert html_response(conn, 200) =~ "Create Your Profile"
    end

    test "redirects to show if user already has a profile", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      {:ok, %Profile{}} = Accounts.create_profile(attrs)

      conn = get(conn, Routes.profile_path(conn, :new))
      assert html_response(conn, 302) =~ "<html><body>You are being <a href=\"/profiles/"
    end

    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.profile_path(conn, :new))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end
  end

  describe "create profile" do
    test "redirects to show when data is valid and user is logged in", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.profile_path(conn, :create), profile: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.profile_path(conn, :show, id)

      conn = get(conn, Routes.profile_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some first_name's Profile"
    end

    test "renders errors when data is invalid and user is logged in", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.profile_path(conn, :create), profile: @invalid_attrs)

      assert html_response(conn, 200) =~ "Create Your Profile"
    end

    test "redirects to login when user is not logged in", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :create), profile: @create_attrs)

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end
  end

  describe "show profile" do
    setup [:create_profile, :create_lt_profile]

    test "redirects to login when user is not logged in", %{conn: conn, profile: profile} do
      conn = get(conn, Routes.profile_path(conn, :show, profile))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end

    test "shows user profile of any user when user is logged in and Admin", %{
      conn: conn,
      profile: profile,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.profile_path(conn, :show, profile))

      assert html_response(conn, 200) =~ "some first_name's Profile"
    end

    test "shows logged in users their own profile", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      {:ok, profile} = Accounts.create_profile(attrs)
      conn = get(conn, Routes.profile_path(conn, :show, profile))
      assert html_response(conn, 200) =~ "some first_name's Profile"
    end

    test "logged in user cannot view other users' profiles", %{
      conn: conn,
      user: user,
      admin: admin
    } do
      conn = log_in_user(conn, admin)
      attrs = Map.put(@create_attrs, :user_id, admin.id)
      {:ok, profile} = Accounts.create_profile(attrs)

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.profile_path(conn, :show, profile))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "logged in user can view the Little Thinker's Profile", %{
      conn: conn,
      lt_profile: lt_profile,
      user: user
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.profile_path(conn, :show, lt_profile))

      assert html_response(conn, 200) =~ "some first_name's Profile"
    end
  end

  describe "edit profile" do
    setup [:create_profile]

    test "renders form for editing profile when user is logged in and owns the profile", %{
      conn: conn,
      user: user
    } do
      conn = log_in_user(conn, user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      {:ok, profile} = Accounts.create_profile(attrs)
      conn = get(conn, Routes.profile_path(conn, :edit, profile))

      assert html_response(conn, 200) =~ "Edit Profile"
    end

    test "logged in users are redirected to home when they attempt to edit other users' profiles",
         %{conn: conn, profile: profile, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.profile_path(conn, :edit, profile))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "redirects to login when user is not logged in", %{conn: conn, profile: profile} do
      conn = get(conn, Routes.profile_path(conn, :edit, profile))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end
  end

  describe "update profile" do
    setup [:create_profile]

    test "redirects when data is valid and logged in users are updating their own profile", %{
      conn: conn,
      user: user
    } do
      conn = log_in_user(conn, user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      {:ok, profile} = Accounts.create_profile(attrs)
      conn = put(conn, Routes.profile_path(conn, :update, profile), profile: @update_attrs)

      assert redirected_to(conn) == Routes.profile_path(conn, :show, profile)

      conn = get(conn, Routes.profile_path(conn, :show, profile))
      assert html_response(conn, 200) =~ "some updated animal"
    end

    test "renders errors when data is invalid and logged in users are updating their own profile",
         %{
           conn: conn,
           user: user
         } do
      conn = log_in_user(conn, user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      {:ok, profile} = Accounts.create_profile(attrs)
      conn = put(conn, Routes.profile_path(conn, :update, profile), profile: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Profile"
    end

    test "logged users are redirected to home when they attempt to update other users' profiles",
         %{
           conn: conn,
           user: user,
           profile: profile
         } do
      conn =
        conn
        |> log_in_user(user)
        |> put(Routes.profile_path(conn, :update, profile), profile: @update_attrs)

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "redirects to login when user is not logged in", %{conn: conn, profile: profile} do
      conn = put(conn, Routes.profile_path(conn, :update, profile), profile: @create_attrs)

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end
  end

  describe "delete profile" do
    setup [:create_profile]

    test "deletes chosen profile when logged in users are deleting their own profile", %{
      conn: conn,
      user: user
    } do
      conn = log_in_user(conn, user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      {:ok, profile} = Accounts.create_profile(attrs)
      conn = delete(conn, Routes.profile_path(conn, :delete, profile))

      assert redirected_to(conn) == Routes.profile_path(conn, :new)

      assert_error_sent 404, fn ->
        get(conn, Routes.profile_path(conn, :show, profile))
      end
    end

    test "redirects to home when users are attempting to delete other users' profiles", %{
      conn: conn,
      user: user,
      profile: profile
    } do
      conn =
        conn
        |> log_in_user(user)
        |> delete(Routes.profile_path(conn, :delete, profile))

      assert html_response(conn, 302) =~ "You are being <a href=\"/home\">redirected</a>."
    end

    test "redirects to login when user is not logged in", %{conn: conn, profile: profile} do
      conn = delete(conn, Routes.profile_path(conn, :delete, profile))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/users/log_in\">redirected</a>.</body></html>"
    end
  end

  defp create_profile(_) do
    profile = profile_fixture()
    %{profile: profile}
  end

  defp create_lt_profile(_) do
    lt_profile = lt_profile_fixture()
    %{lt_profile: lt_profile}
  end
end
