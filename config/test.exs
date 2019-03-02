use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lunchbox_api, LunchboxApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :lunchbox_api, LunchboxApi.Repo,
  username: "root",
  password: "",
  database: "lunchbox_api_test",
  hostname: "localhost",
  port:      26257,
  # pool: Ecto.Adapters.SQL.Sandbox
  pool: EctoReplaySandbox

# Configure Basic_auth for test
config :lunchbox_api, lunchbox_auth: [
  username: System.get_env("BASIC_AUTH_USERNAME"),
  password: System.get_env("BASIC_AUTH_PASSWORD")
]
