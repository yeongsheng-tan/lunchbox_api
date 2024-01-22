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
    ssl_opts: [verify: :verify_peer,
               cacerts: :public_key.cacerts_get(), # supported with OTP26
               versions: [:"tlsv1.3"],
               depth: 3,
               server_name_indication: String.to_charlist(System.get_env("DATABASE_HOST")),
               customize_hostname_check: [
                match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
               ]
              ],
    # Free tier db only allows 1 conn
    pool_size: 2

  config :lunchbox_api, LunchboxApiWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
        ~r"priv/gettext/.*(po)$",
        ~r"lib/lunchbox_api_web/(live|views)/.*(ex)$",
        ~r"lib/lunchbox_api_web/templates/.*(eex)$"
      ]
    ]
end
