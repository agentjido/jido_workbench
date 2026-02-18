defmodule AgentJido.MixProject do
  use Mix.Project

  def project do
    [
      app: :agent_jido,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:phoenix_live_view],
      listeners: [Phoenix.CodeReloader],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AgentJido.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      # Phoenix / Web
      {:phoenix, "~> 1.8.3"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:heroicons, github: "tailwindlabs/heroicons", tag: "v2.1.5", app: false, compile: false, sparse: "optimized"},
      {:floki, "~> 0.35"},
      {:lazy_html, ">= 0.0.0"},
      # HTTP / Server
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.5"},
      {:plug_canonical_host, "~> 2.0"},
      {:phoenix_seo, "~> 0.1.11"},
      {:finch, "~> 0.13"},
      {:swoosh, "~> 1.5"},

      # Assets
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},

      # Telemetry / i18n / Serialization
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},

      # Content / Markdown
      {:nimble_publisher, "~> 1.1"},
      {:makeup_elixir, "~> 1.0"},
      {:makeup_js, "~> 0.1.0"},
      {:makeup_html, "~> 0.2.0"},

      # DB / Ecto (required by Arcana)
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19"},
      {:pgvector, "~> 0.3"},

      # RAG
      {:arcana, "~> 1.3.3"},
      {:leidenfold, "~> 0.3"},

      # Nx backend (Apple Silicon)
      {:emlx, "~> 0.2"},

      # AI / Jido
      {:jido, "~> 2.0.0-rc.5", override: true},
      {:jido_action, github: "agentjido/jido_action", branch: "main", override: true},
      {:jido_signal, github: "agentjido/jido_signal", branch: "main", override: true},
      {:jido_ai, github: "agentjido/jido_ai", branch: "main", override: true},
      {:jido_runic, github: "agentjido/jido_runic", branch: "main"},
      {:jido_live_dashboard, github: "agentjido/jido_live_dashboard", branch: "main"},
      {:libgraph, github: "zblanco/libgraph", branch: "zw/multigraph-indexes", override: true},
      {:jido_studio, github: "agentjido/jido_studio", branch: "main"},
      {:jido_messaging, github: "agentjido/jido_messaging", branch: "main"},
      {:req_llm, github: "agentjido/req_llm", branch: "main", override: true},
      {:llm_db, github: "agentjido/llm_db", branch: "main", override: true},
      {:timex, "~> 3.7", override: true},
      {:gettext, "~> 0.26", override: true},

      # Image generation (OG images)
      {:image, "~> 0.54"},

      # Schema validation
      {:zoi, "~> 0.17"},

      # Config / Env
      {:dotenvy, "~> 1.0"},

      # Dev Tools
      {:tidewave, "~> 0.5", only: :dev},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:git_ops, "~> 2.9", only: :dev, runtime: false},
      {:git_hooks, "~> 0.8", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "arcana.refresh": [
        "content.ingest.local --graph-concurrency 1",
        "arcana.graph.detect_communities --quiet",
        "arcana.graph.summarize_communities --concurrency 1"
      ],
      s: ["agentjido.signal"],
      q: ["quality"],
      quality: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --min-priority higher",
        "dialyzer"
      ]
    ]
  end
end
