use Mix.Config

config :king_of_tokyo, KingOfTokyoWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("KING_OF_TOKYO_PORT", "4000")),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: "theking.live", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  code_reloader: false,
  check_origin: ["//theking.live"]

# Do not print debug messages in production
config :logger,
  backends: [{LoggerFileBackend, :log_file}],
  level: :info

config :logger, :log_file,
  path: "/var/log/the_king/the_king.log",
  level: :info

# Finally import the config/prod.secret.exs which loads secrets
# and configuration from environment variables.
import_config "prod.secret.exs"
