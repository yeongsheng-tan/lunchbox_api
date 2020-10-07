# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lunchbox_api,
  ecto_repos: [LunchboxApi.Repo]

# Configures the endpoint
config :lunchbox_api, LunchboxApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7R/dI10x1tt/FnDkKsdB3QTWRQkX9VVtVGOVFBAuobw/T2G23RJ9RM7nvMsj0+T3",
  render_errors: [view: LunchboxApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LunchboxApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# BasicAuth
config :lunchbox_api, :basic_auth,
  username: System.get_env("BASIC_AUTH_USERNAME"),
  password: System.get_env("BASIC_AUTH_PASSWORD")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
