use Mix.Config

secret_key_base =
  System.get_env("KING_OF_TOKYO_SECRET_KEY_BASE") ||
    raise """
    environment variable KING_OF_TOKYO_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

admin_username =
  System.get_env("KING_OF_TOKYO_ADMIN_USERNAME") ||
    raise """
    environment variable KING_OF_TOKYO_ADMIN_USERNAME is missing.
    """

admin_password =
  System.get_env("KING_OF_TOKYO_ADMIN_PASSWORD") ||
    raise """
    environment variable KING_OF_TOKYO_ADMIN_PASSWORD is missing.
    """

config :king_of_tokyo, KingOfTokyoWeb.Endpoint, secret_key_base: secret_key_base

config :king_of_tokyo,
  admin_username: admin_username,
  admin_password: admin_password
