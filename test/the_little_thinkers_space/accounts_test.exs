defmodule TheLittleThinkersSpace.AccountsTest do
  use TheLittleThinkersSpace.DataCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures

  alias TheLittleThinkersSpace.Accounts
  alias TheLittleThinkersSpace.Accounts.{User, UserToken}

  describe "get_user_by_first_and_last_name/2" do
    test "does not return user if the first and last name combination does not exist" do
      refute Accounts.get_user_by_first_and_last_name("Random", "Random")
    end

    test "returns the user if the first and last name combination exists" do
      %{first_name: first_name, last_name: last_name} = user = user_fixture()

      assert %User{first_name: ^first_name, last_name: ^last_name} =
               Accounts.get_user_by_first_and_last_name(user.first_name, user.last_name)
    end
  end

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:role, :first_name, :last_name, :password, :email]
    end

    test "allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = user_fixture()

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Accounts.get_user!(user.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "update_user/2" do
    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{first_name: "Karen", last_name: "Murphy"}
      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.first_name == "Karen"
      assert user.last_name == "Murphy"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      invalid_update_attrs = %{first_name: nil, last_name: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, invalid_update_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 does returns error changeset when first and last name combination provided already exists" do
      user = user_fixture()
      admin = admin_fixture()
      duplicate_update_attrs = %{first_name: admin.first_name, last_name: admin.last_name}
      {:error, changeset} = Accounts.update_user(user, duplicate_update_attrs)
      assert %{first_name: ["has already been taken"]} == errors_on(changeset)
      assert user == Accounts.get_user!(user.id)
    end
  end

  describe "profiles" do
    alias TheLittleThinkersSpace.Accounts.Profile

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

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Accounts.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Accounts.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      valid_attrs = %{
        animal: "some animal",
        belongs_to_lt: true,
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

      assert {:ok, %Profile{} = profile} = Accounts.create_profile(valid_attrs)
      assert profile.animal == "some animal"
      assert profile.belongs_to_lt == true
      assert profile.birthday == ~D[2021-10-18]
      assert profile.book == "some book"
      assert profile.color == "some color"
      assert profile.first_name == "some first_name"
      assert profile.food == "some food"
      assert profile.future == "some future"
      assert profile.joke == "some joke"
      assert profile.last_name == "some last_name"
      assert profile.movie == "some movie"
      assert profile.nickname == "some nickname"
      assert profile.song == "some song"
      assert profile.superhero == "some superhero"
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()

      update_attrs = %{
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

      assert {:ok, %Profile{} = profile} = Accounts.update_profile(profile, update_attrs)
      assert profile.animal == "some updated animal"
      assert profile.belongs_to_lt == false
      assert profile.birthday == ~D[2021-10-19]
      assert profile.book == "some updated book"
      assert profile.color == "some updated color"
      assert profile.first_name == "some updated first_name"
      assert profile.food == "some updated food"
      assert profile.future == "some updated future"
      assert profile.joke == "some updated joke"
      assert profile.last_name == "some updated last_name"
      assert profile.movie == "some updated movie"
      assert profile.nickname == "some updated nickname"
      assert profile.song == "some updated song"
      assert profile.superhero == "some updated superhero"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_profile(profile, @invalid_attrs)
      assert profile == Accounts.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Accounts.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      # user = user_fixture()
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Accounts.change_profile(profile)
    end
  end

  ## Crew

  describe "connect_users/1" do
    setup do
      %{user: user_fixture(), little_thinker: little_thinker_fixture(), admin: admin_fixture()}
    end

    test "requires two ids and a relationship type" do
      assert {:error, changeset} = Accounts.connect_users(%{})

      assert %{
               little_thinker_id: ["This field must not be empty!"],
               user_id: ["This field must not be empty!"],
               type: ["This field must not be empty!"]
             } = errors_on(changeset)
    end

    test "enters the little thinker/user combination and their relationship to the database when valid ids and relationship type are provided for
      little thinker and the other user",
         %{user: user, little_thinker: little_thinker} do
      user_id = user.id
      little_thinker_id = little_thinker.id
      type = "Friend"

      assert {:ok, %{little_thinker_id: ^little_thinker_id, user_id: ^user_id, type: ^type}} =
               Accounts.connect_users(%{
                 little_thinker_id: little_thinker.id,
                 user_id: user.id,
                 type: type
               })
    end

    test "same combination of little_thinker_id and user_Id cannot be entered twice", %{
      user: user,
      little_thinker: little_thinker
    } do
      user_id = user.id
      little_thinker_id = little_thinker.id
      type = "Friend"

      assert(
        {:ok, %{little_thinker_id: ^little_thinker_id, user_id: ^user_id, type: ^type}} =
          Accounts.connect_users(%{
            little_thinker_id: little_thinker.id,
            user_id: user.id,
            type: type
          })
      )

      assert {:error, changeset} =
               Accounts.connect_users(%{
                 little_thinker_id: little_thinker.id,
                 user_id: user.id,
                 type: type
               })

      assert %{little_thinker_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "same little_thinker_id can be entered with different user_ids", %{
      user: user,
      little_thinker: little_thinker,
      admin: admin
    } do
      user_id = user.id
      little_thinker_id = little_thinker.id
      admin_id = admin.id
      type = "Friend"

      assert(
        {:ok, %{little_thinker_id: ^little_thinker_id, user_id: ^user_id, type: ^type}} =
          Accounts.connect_users(%{
            little_thinker_id: little_thinker.id,
            user_id: user.id,
            type: type
          })
      )

      assert(
        {:ok, %{little_thinker_id: ^little_thinker_id, user_id: ^admin_id, type: ^type}} =
          Accounts.connect_users(%{
            little_thinker_id: little_thinker.id,
            user_id: admin.id,
            type: type
          })
      )
    end

    test "one user_id can be entered with different little_thinker_ids", %{
      user: user,
      little_thinker: little_thinker,
      admin: admin
    } do
      user_id = user.id
      little_thinker_id = little_thinker.id
      admin_id = admin.id
      type = "Friend"

      assert(
        {:ok, %{little_thinker_id: ^little_thinker_id, user_id: ^user_id, type: ^type}} =
          Accounts.connect_users(%{
            little_thinker_id: little_thinker.id,
            user_id: user.id,
            type: type
          })
      )

      assert(
        {:ok, %{little_thinker_id: ^admin_id, user_id: ^user_id, type: ^type}} =
          Accounts.connect_users(%{little_thinker_id: admin.id, user_id: user.id, type: type})
      )
    end
  end
end
