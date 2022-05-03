defmodule TheLittleThinkersSpace.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Accounts` context.
  """

  alias TheLittleThinkersSpace.{Accounts, Repo}

  @valid_profile_attrs %{
    animal: "some animal",
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

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_user_role, do: "Crew"
  def admin_role, do: "Admin"
  def little_thinker_role, do: "The Little Thinker"
  def valid_user_first_name, do: "Waldo"
  def valid_user_last_name, do: "Butters#{System.unique_integer()}"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      role: valid_user_role(),
      first_name: valid_user_first_name(),
      last_name: valid_user_last_name()
    })
  end

  def admin_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      role: admin_role(),
      first_name: valid_user_first_name(),
      last_name: valid_user_last_name()
    })
  end

  def little_thinker_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      role: little_thinker_role(),
      first_name: valid_user_first_name(),
      last_name: valid_user_last_name()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  def user(_context) do
    {:ok, user} = Accounts.register_user(valid_user_attributes())
    %{user: user}
  end

  def little_thinker(_context) do
    {:ok, little_thinker} = Accounts.register_user(little_thinker_attributes())
    %{little_thinker: little_thinker}
  end

  def admin(_context) do
    {:ok, admin} = Accounts.register_user(admin_attributes())
    %{admin: admin}
  end

  def with_crew(%{little_thinker: little_thinker}) do
    {:ok, friend} = Accounts.register_user(little_thinker_attributes())

    Accounts.connect_users(%{
      little_thinker_id: little_thinker.id,
      user_id: friend.id,
      type: "Friend"
    })

    little_thinker = Repo.preload(little_thinker, [:crews])

    %{little_thinker: little_thinker}
  end

  def with_little_thinker(%{user: user}) do
    {:ok, little_thinker} = Accounts.register_user(little_thinker_attributes())

    Accounts.connect_users(%{
      little_thinker_id: little_thinker.id,
      user_id: user.id,
      type: "Friend"
    })

    user = Repo.preload(user, [:little_thinkers])

    %{user: user}
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  # Profiles

  def profile(_context) do
    {:ok, profile} = Accounts.create_profile(@valid_profile_attrs)
    %{profile: profile}
  end

  def user_profile(%{user: user}) do
    user_profile_attrs = Map.merge(@valid_profile_attrs, %{user_id: user.id})
    {:ok, user_profile} = Accounts.create_profile(user_profile_attrs)
    %{user_profile: user_profile}
  end

  def lt_profile(%{little_thinker: little_thinker}) do
    lt_profile_attrs = Map.merge(@valid_profile_attrs, %{user_id: little_thinker.id})
    {:ok, lt_profile} = Accounts.create_profile(lt_profile_attrs)
    %{lt_profile: lt_profile}
  end
end
