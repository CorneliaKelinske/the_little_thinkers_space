defmodule TheLittleThinkersSpace.Repo do
  use Ecto.Repo,
    otp_app: :the_little_thinkers_space,
    adapter: Ecto.Adapters.Postgres
end
