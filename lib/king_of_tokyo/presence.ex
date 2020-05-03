defmodule KingOfTokyoWeb.Presence do
  @moduledoc false

  use Phoenix.Presence, otp_app: :king_of_tokyo, pubsub_server: KingOfTokyo.PubSub

  alias KingOfTokyo.GameServer

  def fetch(topic, presences) do
    {:ok, players} = GameServer.list_players(topic)

    players
    |> Enum.reduce(presences, fn %{id: id} = player, acc ->
      case acc[id] do
        %{metas: _} ->
          put_in(acc, [id, :player], player)

        _ ->
          acc
      end
    end)
  end
end
