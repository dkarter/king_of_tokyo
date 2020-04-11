use Mix.Config

secret_key_base =
  System.get_env("KING_OF_TOKYO_SECRET_KEY_BASE") ||
    raise """
    environment variable KING_OF_TOKYO_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :king_of_tokyo, KingOfTokyoWeb.Endpoint, secret_key_base: secret_key_base
