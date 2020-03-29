defmodule KingOfTokyo.GameSupervisor do
  @moduledoc """
  Dynamically starts a game server
  """

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(game_name) do
    child_spec = %{
      id: KingOfTokyo.GameServer,
      start: {KingOfTokyo.GameServer, :start_link, [game_name]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_game(game_name) do
    case KingOfTokyo.GameServer.game_pid(game_name) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      nil ->
        :ok
    end
  end
end
