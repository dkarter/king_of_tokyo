use Mix.Config

defmodule EnvHelper do
  def get_env!(var_name) do
    System.get_env(var_name) ||
      raise """
      environment variable #{var_name} is missing.
      """
  end
end

secret_key_base = EnvHelper.get_env!("KING_OF_TOKYO_SECRET_KEY_BASE")
admin_username = EnvHelper.get_env!("KING_OF_TOKYO_ADMIN_USERNAME")
admin_password = EnvHelper.get_env!("KING_OF_TOKYO_ADMIN_PASSWORD")
logflare_api_key = EnvHelper.get_env!("KING_OF_TOKYO_LOGFLARE_API_KEY")
logflare_source_id = EnvHelper.get_env!("KING_OF_TOKYO_LOGFLARE_SOURCE_ID")

config :logflare_logger_backend,
  url: "https://api.logflare.app",
  level: :info,
  api_key: logflare_api_key,
  source_id: logflare_source_id,
  flush_interval: 1_000,
  max_batch_size: 50

config :king_of_tokyo, KingOfTokyoWeb.Endpoint, secret_key_base: secret_key_base

config :king_of_tokyo,
  admin_username: admin_username,
  admin_password: admin_password
