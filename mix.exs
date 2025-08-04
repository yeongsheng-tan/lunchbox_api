defmodule LunchboxApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :lunchbox_api,
      version: "1.16.7",
      elixir: "~> 1.18.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:leex, :yecc] ++ Mix.compilers(),
      
      # Test coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ],
      
      # Documentation
      name: "LunchboxApi",
      source_url: "https://github.com/your-org/lunchbox_api",
      homepage_url: "https://your-org.github.io/lunchbox_api",
      docs: [
        main: "LunchboxApi",
        extras: ["README.md"]
      ],
      
      # Dialyzer
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ],
      
      releases: [
        lunchbox_api: [
          cookie: "0Q@X,WNlR$C~4I=Ch{P&FCFlP|Wy>lpccA^D()2H3iwKU;/DQ&7p@6zC@DzKS,xk",
          include_erts: true,
          applications: [lunchbox_api: :permanent]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LunchboxApi.Application, []},
      extra_applications: [:sasl, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, "~> 0.17"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.20"},
      {:floki, "~> 0.35", only: :test},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.24"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.6"},
      {:plug_forwarded_peer, "~> 0.1.0"},
      {:file_system, "~> 1.0", override: true},
      # Authentication
      {:joken, "~> 2.5"},
      {:oauth2, "~> 2.1"},
      # Testing & Quality
      {:mox, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.7", only: :test},
      {:bypass, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.18", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:doctor, "~> 0.21", only: :dev},
      {:stream_data, "~> 0.6", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # Asset management
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      
      # Database management
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      
      # Testing
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "test.integration": ["test --only integration"],
      "test.performance": ["test --only performance"],
      "test.property": ["test test/property/"],
      "test.coverage": ["coveralls.html"],
      "test.watch": ["test.watch"],
      
      # Quality assurance
      quality: ["format", "credo --strict", "dialyzer", "test"],
      "quality.ci": ["format --check-formatted", "credo --strict", "dialyzer", "coveralls.cobertura"],
      
      # Documentation
      docs: ["docs", "cmd open doc/index.html"],
      "docs.publish": ["hex.publish docs"]
    ]
  end
end
