import Config

if config_env() == :prod do
  config :lunchbox_api, LunchboxApiWeb.Endpoint,
    http: [:inet6, port: System.get_env("PORT") || 4000],
    server: true,
    check_origin: ["//*.gigalixirapp.com"],
    secret_key_base: System.get_env("SECRET_KEY_BASE"),
    url: [host: "gigalixirapp.com", port: 80],
    cache_static_manifest: "priv/static/cache_manifest.json"

  config :lunchbox_api, LunchboxApi.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_URL"),
    database: "",
    ssl: true,
    ssl_opts: [verify: :verify_none],
    # Free tier db only allows 1 conn
    pool_size: 2
end
