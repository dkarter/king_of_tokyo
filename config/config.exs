# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :king_of_tokyo, KingOfTokyoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NTgl0xISBNgY2ptug3o7jRZHHTuZLk55PkafMNDuuA4fF/hiV8Kv+i2Nd135UJYC",
  render_errors: [view: KingOfTokyoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: KingOfTokyo.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "k7DcUyJV84u/p1HGn9/G12KANWC85x7B"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
