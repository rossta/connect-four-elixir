use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :play_four, PlayFourWeb.Endpoint,
  http: [port: System.get_env("PORT") || 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :play_four, PlayFour.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("POSTGRESQL_PASSWORD") || "postgres",
  hostname: System.get_env("POSTGRESQL_HOST") || "localhost",
  database: "connect_four_test",
  pool: Ecto.Adapters.SQL.Sandbox
