import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lunchbox_api, LunchboxApiWeb.Endpoint,
  http: [port: 4002],
  url: [host: "localhost", port: 4002],
  server: false

# Suppress most logs during test
config :logger, level: :warning

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :warning],
    [module: LunchboxApi.Auth, function: "authenticate/3"],
    [module: LunchboxApi.Auth, function: :authenticate]
  ]


config :lunchbox_api, LunchboxApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "lunchbox_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  # Optimize for test performance
  pool_size: 10,
  ownership_timeout: 10_000,
  timeout: 5_000,
  queue_target: 50,
  queue_interval: 100

# OAuth configuration for testing
config :lunchbox_api, :github_oauth,
  client_id: "test_client_id",
  client_secret: "test_client_secret",
  authorize_url: "https://github.com/login/oauth/authorize",
  token_url: "https://github.com/login/oauth/access_token"



config :joken,
  default_signer: "test_secret_key_for_integration_tests_that_is_long_enough_to_meet_requirements"



# Configure OAuth2 to use mock HTTP client in test environment
config :oauth2, client: OAuth2.Client.HTTPC

# Use mock implementations in test environment
config :lunchbox_api, :auth_impl, LunchboxApi.Auth.Mock
config :lunchbox_api, :oauth_impl, LunchboxApi.Auth.OAuth.Mock
config :lunchbox_api, :users_impl, LunchboxApi.Users.Mock
config :lunchbox_api, :jwt_impl, LunchboxApi.Auth.JWT.Mock

# Ensure the application uses the mock implementations
config :lunchbox_api, LunchboxApi.Auth, impl: LunchboxApi.Auth.Mock
config :lunchbox_api, LunchboxApi.Users, impl: LunchboxApi.Users.Mock
config :lunchbox_api, LunchboxApi.Auth.JWT, impl: LunchboxApi.Auth.JWT.Mock
