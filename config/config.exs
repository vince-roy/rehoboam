# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :rehoboam,
  ecto_repos: [Rehoboam.Repo],
  file_upload: Rehoboam.FileUploadLocal

# Configures the endpoint
config :rehoboam, RehoboamWeb.Endpoint,
  cdn_url: "",
  files_directory: "./files",
  url: [host: "localhost"],
  render_errors: [view: RehoboamWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Rehoboam.PubSub,
  live_view: [signing_salt: "JAsi7mnW"],
  ssr: true,
  use_vite_server: false

config :ex_aws,
  json_codec: Jason

config :ex_aws, :s3,
  app: "rehoboam",
  scheme: "https://",
  host: "",
  region: ""

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :rehoboam, Rehoboam.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, :adapter, {Tesla.Adapter.Finch, [name: RehoboamFinch, receive_timeout: 60_000]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
