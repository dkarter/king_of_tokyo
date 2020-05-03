defmodule KingOfTokyo.GameGarbageCollector do
  @moduledoc """
  Stops games with no active players
  """

  use GenServer

  alias KingOfTokyo.GameServer

  require Logger

  @garbage_collection_interval :timer.minutes(2)

  def start_link(_) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init([]) do
    {:ok, timer} = :timer.send_interval(@garbage_collection_interval, :garbage_collect)

    {:ok, %{garbage_collector_timer: timer}}
  end

  @impl GenServer
  def handle_info(:garbage_collect, state) do
    KingOfTokyo.GameSupervisor.which_children()
    |> Enum.each(fn {_, game_server_pid, _, _} ->
      {:ok, game} = GameServer.get_game(game_server_pid)

      game_id = game.code.game_id

      presence_player_ids = GameServer.presence_player_ids(game_id)

      if presence_player_ids == [] do
        Logger.info("No more players present on: #{game_id}, shutting down game server...")
        KingOfTokyo.GameSupervisor.stop_game(game_id)
      end
    end)

    {:noreply, state}
  end
end
