defmodule KingOfTokyo.GameServerTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.GameServer
  alias KingOfTokyo.Player

  describe ".start_link" do
    test "starts a new game" do
      assert {:ok, pid} = GameServer.start_link(Ecto.UUID.generate())
      assert is_pid(pid)
    end
  end

  describe ".add_player/2" do
    test "adds a player to the game instance" do
      game_id = Ecto.UUID.generate()
      player = Player.new("Joe", :the_king)
      {:ok, _pid} = GameServer.start_link(game_id)
      assert :ok = GameServer.add_player(game_id, player)
      assert {:ok, [^player]} = GameServer.list_players(game_id)
    end

    test "returns an error if a player with the same name already exists" do
      game_id = Ecto.UUID.generate()
      player = Player.new("Joe", :the_king)
      {:ok, _pid} = GameServer.start_link(game_id)
      assert :ok = GameServer.add_player(game_id, player)
      assert {:error, :name_taken} = GameServer.add_player(game_id, player)
      assert {:ok, [^player]} = GameServer.list_players(game_id)
    end
  end

  describe ".update_player/2" do
    test "updates a player in the game instance" do
      game_id = Ecto.UUID.generate()
      player = Player.new("Joe", :the_king)
      {:ok, _pid} = GameServer.start_link(game_id)
      :ok = GameServer.add_player(game_id, player)
      updated_player = Map.put(player, :character, :giga_zaur)
      assert :ok = GameServer.update_player(game_id, updated_player)
      assert {:ok, [^updated_player]} = GameServer.list_players(game_id)
    end

    test "returns an error if player is not found" do
      game_id = Ecto.UUID.generate()
      player = Player.new("joe", :the_king)
      {:ok, _pid} = GameServer.start_link(game_id)

      assert {:error, :player_not_found} = GameServer.update_player(game_id, player)
    end
  end

  describe ".remove_player/2" do
    test "removes a player from the game instance" do
      game_id = Ecto.UUID.generate()
      player = Player.new("Joe", :the_king)
      {:ok, _pid} = GameServer.start_link(game_id)
      :ok = GameServer.add_player(game_id, player)
      assert :ok = GameServer.remove_player(game_id, player.id)
      assert {:ok, []} = GameServer.list_players(game_id)
    end

    test "returns :ok and ignores request if player is not found" do
      game_id = Ecto.UUID.generate()
      {:ok, _pid} = GameServer.start_link(game_id)
      assert :ok = GameServer.remove_player(game_id, "foobar")
    end
  end

  describe ".reset_dice/1" do
    test "resets roll results, dice counts and dice selections" do
      game_id = Ecto.UUID.generate()
      {:ok, _pid} = GameServer.start_link(game_id)

      assert {:ok, dice_state} = GameServer.reset_dice(game_id)
      assert {:ok, ^dice_state} = GameServer.get_dice_state(game_id)

      assert %{
               dice_count: 6,
               roll_count: 0,
               roll_result: [],
               selected_roll_results: []
             } = dice_state
    end
  end

  describe ".roll_dice/1" do
    test "generates new dice results and updates roll counts" do
      game_id = Ecto.UUID.generate()
      {:ok, _pid} = GameServer.start_link(game_id)

      assert {:ok, dice_state} = GameServer.roll_dice(game_id)
      assert {:ok, ^dice_state} = GameServer.get_dice_state(game_id)

      assert %{
               dice_count: 6,
               roll_count: 1,
               roll_result: [_, _, _, _, _, _],
               selected_roll_results: []
             } = dice_state
    end
  end

  describe ".re_roll_dice/1" do
    test "generates new dice results and updates roll counts" do
      game_id = Ecto.UUID.generate()
      {:ok, _pid} = GameServer.start_link(game_id)

      assert {:ok, dice_state} = GameServer.roll_dice(game_id)

      die_2 = Enum.at(dice_state.roll_result, 1)
      die_5 = Enum.at(dice_state.roll_result, 4)

      {:ok, _dice_state} = GameServer.toggle_selected_dice_index(game_id, 1)
      {:ok, _dice_state} = GameServer.toggle_selected_dice_index(game_id, 4)

      assert {:ok, dice_state} = GameServer.re_roll_dice(game_id)

      assert %{
               dice_count: 6,
               roll_count: 2,
               roll_result: [_, ^die_2, _, _, ^die_5, _],
               selected_roll_results: [4, 1]
             } = dice_state
    end
  end

  describe ".set_dice_count/2" do
    test "updates the dice count for everyone" do
      game_id = Ecto.UUID.generate()
      {:ok, _pid} = GameServer.start_link(game_id)

      assert {:ok, %{dice_count: 5}} = GameServer.set_dice_count(game_id, 5)
    end
  end
end
