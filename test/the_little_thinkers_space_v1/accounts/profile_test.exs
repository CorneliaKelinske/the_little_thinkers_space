defmodule TheLittleThinkersSpace.Accounts.ProfileTest do
  use TheLittleThinkersSpace.DataCase

  alias TheLittleThinkersSpace.Accounts
  alias TheLittleThinkersSpace.Accounts.Profile
  import TheLittleThinkersSpace.AccountsFixtures

  @profile_params %{
    first_name: "something",
    last_name: "something",
    nickname: "something",
    birthday: ~D[2021-10-18],
    color: "something",
    animal: "something",
    food: "something",
    superhero: "something",
    song: "something",
    movie: "something",
    book: "something",
    future: "something",
    joke: "something",
    belongs_to_lt: false
  }

  setup do
    %{user: user_fixture()}
  end

  describe "changeset/2" do
    test "cannot insert a profile with a duplicate user_id", %{user: %{id: user_id}} do
      params = Map.merge(@profile_params, %{user_id: user_id})
      assert {:ok, %Profile{}} = Accounts.create_profile(params)
      assert {:error, %Ecto.Changeset{errors: errors}} = Accounts.create_profile(params)
    end
  end
end
