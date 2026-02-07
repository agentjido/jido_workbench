defmodule JidoWorkbench.MixProject do
  use Mix.Project

  def project do
    [
      app: :jido_workbench,
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
      mod: {JidoWorkbench.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix / Web
      {:phoenix, "~> 1.8.3"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:heroicons, github: "tailwindlabs/heroicons", tag: "v2.1.5", app: false, compile: false, sparse: "optimized"},
      {:floki, "~> 0.35"},
      {:lazy_html, ">= 0.0.0", only: :test},
      {:petal_components, "~> 3.0.1"},

      # HTTP / Server
      {:plug_cowboy, "~> 2.5"},
      {:plug_canonical_host, "~> 2.0"},
      {:phoenix_seo, "~> 0.1.11"},
      {:finch, "~> 0.13"},
      {:httpoison, "~> 2.0"},
      {:swoosh, "~> 1.5"},

      # Assets
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},

      # Telemetry / i18n / Serialization
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},

      # Content / Markdown
      {:nimble_publisher, "~> 1.1"},
      {:makeup_elixir, "~> 1.0"},
      {:makeup_js, "~> 0.1.0"},
      {:makeup_html, "~> 0.2.0"},

      # AI / Jido
      {:jido, "~> 2.0.0-rc.4"},
      {:jido_ai, github: "agentjido/jido_ai", branch: "main"},
      {:req_llm, "~> 1.5"},

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
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
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
