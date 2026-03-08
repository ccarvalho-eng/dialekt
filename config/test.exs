import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dialekt, DialektWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nawo2U1flXrHqRk+X7zkiRL6S+jFbxCP415cjA7sNw8ipZetOUQ2gQOhcnI4PRLq",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure Ecto Repo for testing
config :dialekt, Dialekt.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "dialekt_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2
