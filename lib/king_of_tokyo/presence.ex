defmodule KingOfTokyoWeb.Presence do
  @moduledoc false

  use Phoenix.Presence, otp_app: :king_of_tokyo, pubsub_server: KingOfTokyo.PubSub
end
