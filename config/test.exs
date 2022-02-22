import Config

config :argon2_elixir, t_cost: 1, m_cost: 8
# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :the_little_thinkers_space, TheLittleThinkersSpace.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "the_little_thinkers_space_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :the_little_thinkers_space, TheLittleThinkersSpaceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "CoRmxS4D/bImA5hlLOjs2v4NQju0q9FaCUDpM79rI9TavWP6puAS6bwyck4Svssm",
  server: false

# In test we don't send emails.
config :the_little_thinkers_space, TheLittleThinkersSpace.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :the_little_thinkers_space, data_path: "priv/static/images/data/test"
