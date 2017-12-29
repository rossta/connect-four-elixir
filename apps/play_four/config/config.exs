# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :play_four,
  ecto_repos: [PlayFour.Repo]

# Configures the endpoint
config :play_four, PlayFourWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VJFvSEVw04hyse+Oq9RMmm6kel6TgYAIGanxOmMfpfkvQyyMyuUSymTIjbEn1PKa",
  render_errors: [view: PlayFourWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: PlayFour.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
