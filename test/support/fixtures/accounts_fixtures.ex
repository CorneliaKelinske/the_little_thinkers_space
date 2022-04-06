defmodule TheLittleThinkersSpace.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheLittleThinkersSpace.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_user_role, do: "Friend"
  def admin_role, do: "Admin"
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

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> TheLittleThinkersSpace.Accounts.register_user()

    user
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, admin} =
      attrs
      |> admin_attributes()
      |> TheLittleThinkersSpace.Accounts.register_user()

    admin
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> Enum.into(%{
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
      })
      |> TheLittleThinkersSpace.Accounts.create_profile()

    profile
  end

  def lt_profile_fixture(attrs \\ %{}) do
    {:ok, lt_profile} =
      attrs
      |> Enum.into(%{
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
      })
      |> TheLittleThinkersSpace.Accounts.create_profile()

    lt_profile
  end
end
