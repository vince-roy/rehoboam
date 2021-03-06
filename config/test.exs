import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :rehoboam, Rehoboam.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "rehoboam_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :rehoboam,
  file_upload: Rehoboam.FileUploadMock

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rehoboam, RehoboamWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "5Ng4Icn4H197bWzXVWZMn1CTdnej6h5AOHZpBLJUr+l6VnSIknjwA2oPuI83I4Jw",
  server: false

# In test we don't send emails.
config :rehoboam, Rehoboam.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

if System.get_env("DATABASE_URL") === nil do
  import_config "test.secret.exs"
end

config :potionx,
  auth: %{
    strategies: [
      test: [
        strategy: Potionx.Auth.Provider.Test
      ]
    ]
  }

config :wallaby,
  driver: Wallaby.Chrome,
  otp_app: :rehoboam,
  screenshot_on_failure: false
