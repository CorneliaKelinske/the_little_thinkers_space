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

alias TheLittleThinkersSpace.Accounts

Accounts.register_user(%{
  "name" => "Ramona",
  "email" => "ramona@example.com",
  "password" => "SecretSecret!",
  "role" => "Admin"
})

Accounts.register_user(%{
  "name" => "Ulrik",
  "email" => "ulrik@example.com",
  "password" => "SecretSecret!",
  "role" => "The Little Thinker"
})

Accounts.register_user(%{
  "name" => "Harry",
  "email" => "dresden@example.com",
  "password" => "ForzareForzare!",
  "role" => "friend"
})
