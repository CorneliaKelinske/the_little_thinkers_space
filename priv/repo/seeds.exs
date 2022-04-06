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

alias TheLittleThinkersSpace.{Accounts, Repo, Accounts.User}

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
little_thinker = Repo.get_by(User, role: "The Little Thinker" )
little_thinker_id = little_thinker.id

for user <- users, user.role != "The Little Thinker" do
  Accounts.link_crew(%{little_thinker_id: little_thinker.id, crew_id: user.id})
end
