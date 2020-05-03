defmodule KingOfTokyo.GameSupervisor do
  @moduledoc """
  Dynamically starts a game server
  """

  use DynamicSupervisor

  alias KingOfTokyo.GameCode
  alias KingOfTokyo.GameServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_game(GameCode.t()) :: {:ok, pid()} | {:error, {:already_started, pid()}}
  def start_game(%GameCode{} = code) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [code]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec stop_game(String.t()) :: :ok
  def stop_game(game_id) do
    case KingOfTokyo.GameServer.game_pid(game_id) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      nil ->
        :ok
    end
  end

  def which_children do
    Supervisor.which_children(__MODULE__)
  end
end
