# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tea, :scopes,
  user: [
    default: true,
    module: Tea.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: Tea.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ]

config :tea,
  generators: [timestamp_type: :utc_datetime]

config :tea,
  ecto_repos: [Tea.Repo],
  show_drafts: false

# Use logger adapter as a safe default for environments that do not
# override Tea.Mailer (e.g., production before SMTP/API setup).
config :tea, Tea.Mailer, adapter: Swoosh.Adapters.Logger

# Google OAuth credentials — override per environment (see runtime.exs for prod)
config :tea,
  google_client_id: System.get_env("GOOGLE_CLIENT_ID", ""),
  google_client_secret: System.get_env("GOOGLE_CLIENT_SECRET", ""),
  google_req_options: []

# Configure the endpoint
config :tea, TeaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TeaWeb.ErrorHTML, json: TeaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Tea.PubSub,
  live_view: [signing_salt: "sok4RsQp"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  tea: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  tea: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :swoosh, :api_client, false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
