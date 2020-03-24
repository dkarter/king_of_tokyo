defmodule KingOfTokyo.GameSupervisorTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.GameServer
  alias KingOfTokyo.GameSupervisor

  describe ".start_game/1" do
    test "spawns and registers a new game server process" do
      game_name = Ecto.UUID.generate()

      assert {:ok, _pid} = GameSupervisor.start_game(game_name)

      assert game_name
             |> GameServer.game_pid()
             |> Process.alive?()
    end

    test "returns :error if already started" do
      game_name = Ecto.UUID.generate()

      assert {:ok, pid} = GameSupervisor.start_game(game_name)

      assert {:error, {:already_started, ^pid}} =
               game_name
               |> GameSupervisor.start_game()
    end
  end

  describe ".stop_game/1" do
    test "terminates the game server" do
      game_name = Ecto.UUID.generate()

      assert {:ok, _pid} = GameSupervisor.start_game(game_name)

      via = GameServer.via_tuple(game_name)

      assert :ok = GameSupervisor.stop_game(game_name)
      assert nil == GenServer.whereis(via)
    end

    test "ignores command if already terminated" do
      game_name = Ecto.UUID.generate()
      assert :ok = GameSupervisor.stop_game(game_name)
    end
  end
end
