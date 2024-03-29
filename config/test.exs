import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lunchbox_api, LunchboxApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Configure your database
config :lunchbox_api, LunchboxApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "lunchbox_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
