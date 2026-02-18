# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :agent_jido,
  ecto_repos: [AgentJido.Repo]

config :agent_jido, AgentJido.Repo, types: AgentJido.PostgrexTypes

# Configures the endpoint
config :agent_jido, AgentJidoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AgentJidoWeb.ErrorHTML, json: AgentJidoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AgentJido.PubSub,
  live_view: [signing_salt: "8Hv+cWMw"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :agent_jido, AgentJido.Mailer, adapter: Swoosh.Adapters.Local

config :agent_jido, AgentJido.Jido,
  max_tasks: 1000,
  agent_pools: []

config :agent_jido, AgentJidoWeb.ContentOpsGithubLive,
  owner: "agentjido",
  repo: "agentjido_xyz",
  cache_ttl_minutes: 15,
  contentops_timeout_ms: 60_000,
  github_mutations_enabled: false

contentops_chat_bindings = [
  %{
    room_id: "contentops:lobby",
    room_name: "ContentOps Lobby",
    telegram_chat_id: "645038810",
    discord_channel_id: "1468796189997662487"
  }
]

config :agent_jido, AgentJido.ContentOps.Chat,
  enabled: config_env() == :dev,
  bindings: contentops_chat_bindings,
  allowed_telegram_user_ids: ["645038810"],
  allowed_discord_user_ids: ["281856954903691264", "1235534042062131258"],
  bot_name: "AgentJido",
  command_prefix: "/ops",
  github_owner: "agentjido",
  github_repo: "agentjido_xyz",
  github_labels_base: ["contentops", "chatops"],
  github_labels_docs_note: ["docs-note"],
  mutation_tools_enabled: config_env() == :dev

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.15.5",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  default: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Nx backend (Apple Silicon / EMLX) - used for local Nx/Bumblebee workloads
config :nx,
  default_backend: EMLX.Backend,
  default_defn_options: [compiler: EMLX]

# Arcana RAG
config :arcana,
  repo: AgentJido.Repo,
  embedder: :openai

config :agent_jido, arcana_graph_ingest_concurrency: 1

config :agent_jido, ash_domains: [AgentJido.Folio]

# Git hooks and git_ops configuration for conventional commits
# Only configure when the dependencies are actually available (dev environment)
if config_env() == :dev do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      commit_msg: [
        tasks: [
          {:cmd, "mix git_ops.check_message", include_hook_args: true}
        ]
      ]
    ]

  config :git_ops,
    mix_project: AgentJido.MixProject,
    changelog_file: "CHANGELOG.md",
    repository_url: "https://github.com/agentjido/agent_jido",
    manage_mix_version?: true,
    version_tag_prefix: "v",
    types: [
      feat: [header: "Features"],
      fix: [header: "Bug Fixes"],
      perf: [header: "Performance"],
      refactor: [header: "Refactoring"],
      docs: [hidden?: true],
      test: [hidden?: true],
      chore: [hidden?: true],
      ci: [hidden?: true]
    ]
end

config :jido, jido_instance: AgentJido.Jido
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
