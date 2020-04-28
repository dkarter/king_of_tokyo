defmodule KingOfTokyo.GameSupervisorTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.GameCode
  alias KingOfTokyo.GameServer
  alias KingOfTokyo.GameSupervisor

  describe ".start_game/1" do
    test "spawns and registers a new game server process" do
      %{game_id: game_id} = code = GameCode.new()

      assert {:ok, _pid} = GameSupervisor.start_game(code)

      assert game_id
             |> GameServer.game_pid()
             |> Process.alive?()
    end

    test "returns :error if already started" do
      code = GameCode.new()

      assert {:ok, pid} = GameSupervisor.start_game(code)
      assert {:error, {:already_started, ^pid}} = GameSupervisor.start_game(code)
    end
  end

  describe ".stop_game/1" do
    test "terminates the game server" do
      %{game_id: game_id} = code = GameCode.new()

      assert {:ok, pid} = GameSupervisor.start_game(code)

      assert :ok = GameSupervisor.stop_game(game_id)
      refute Process.alive?(pid)
    end

    test "ignores command if already terminated" do
      game_id = Ecto.UUID.generate()
      assert :ok = GameSupervisor.stop_game(game_id)
    end
  end
end
