# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :arcade,
  namespace: Arcade

# Configures the endpoint
config :arcade, ArcadeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DgGBGF8JVR9K17zgxhpwuxs7gYVocXNUgOmx7fgcE6Rw3hf7vmYs8CgMUd1YsF7Y",
  render_errors: [view: ArcadeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Arcade.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
