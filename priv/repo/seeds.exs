# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TheLittleThinkersSpace.Repo.insert!(%TheLittleThinkersSpace.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TheLittleThinkersSpace.{Accounts}

Accounts.register_user(%{
  "first_name" => "Ramona",
  "last_name" => "Heinrich",
  "email" => "ramona@example.com",
  "password" => "SecretSecret!",
  "role" => "Admin"
})

Accounts.register_user(%{
  "first_name" => "Ulrik",
  "last_name" => "Puppel",
  "email" => "ulrik@example.com",
  "password" => "SecretSecret!",
  "role" => "The Little Thinker"
})

Accounts.register_user(%{
  "first_name" => "Harry",
  "last_name" => "Dresden",
  "email" => "dresden@example.com",
  "password" => "ForzareForzare!",
  "role" => "Friend"
})

users = Accounts.list_users()
little_thinker = Accounts.get_user_by_first_and_last_name("Ulrik", "Puppel")
little_thinker_id = little_thinker.id

for user <- users, user.role != "The Little Thinker" do
  Accounts.connect_users(%{little_thinker_id: little_thinker.id, user_id: user.id, type: "Friend"})
end
