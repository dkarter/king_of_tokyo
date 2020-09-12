defmodule KingOfTokyo.GameServerTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.Game
  alias KingOfTokyo.GameCode
  alias KingOfTokyo.GameServer
  alias KingOfTokyo.Player

  setup do
    %{game_id: game_id} = code = GameCode.new()
    {:ok, _pid} = GameServer.start_link(code)
    {:ok, %{game_id: game_id}}
  end

  describe ".game_pid/1" do
    test "returns the game's pid", %{game_id: game_id} do
      pid = GameServer.game_pid(game_id)
      assert is_pid(pid)
    end

    test "returns nil when does not exist" do
      assert nil == GameServer.game_pid("foobar")
    end
  end

  describe ".add_player/2" do
    test "adds a player to the game instance", %{game_id: game_id} do
      player = Player.new("Joe", :the_king)

      assert :ok = GameServer.add_player(game_id, player)
      assert {:ok, [^player]} = GameServer.list_players(game_id)
    end

    test "returns an error if player with the same character already exists", %{game_id: game_id} do
      player = Player.new("Joe", :the_king)

      assert :ok = GameServer.add_player(game_id, player)
      assert {:error, :character_taken} = GameServer.add_player(game_id, player)
      assert {:ok, [^player]} = GameServer.list_players(game_id)
    end

    test "returns an error if a player with the same name already exists", %{game_id: game_id} do
      player = Player.new("Joe", :the_king)

      assert :ok = GameServer.add_player(game_id, player)

      assert {:error, :name_taken} =
               GameServer.add_player(game_id, Player.new("Joe", :meka_dragon))

      assert {:ok, [^player]} = GameServer.list_players(game_id)
    end
  end

  describe ".update_player/2" do
    test "updates a player in the game instance", %{game_id: game_id} do
      player = Player.new("Joe", :the_king)
      :ok = GameServer.add_player(game_id, player)
      updated_player = Map.put(player, :character, :giga_zaur)

      assert :ok = GameServer.update_player(game_id, updated_player)
      assert {:ok, [^updated_player]} = GameServer.list_players(game_id)
    end

    test "returns an error if player is not found", %{game_id: game_id} do
      player = Player.new("joe", :the_king)

      assert {:error, :player_not_found} = GameServer.update_player(game_id, player)
    end
  end

  describe ".remove_player/2" do
    test "removes a player from the game instance", %{game_id: game_id} do
      player = Player.new("Joe", :the_king)
      :ok = GameServer.add_player(game_id, player)

      assert :ok = GameServer.remove_player(game_id, player.id)
      assert {:ok, []} = GameServer.list_players(game_id)
    end

    test "returns :ok and ignores request if player is not found", %{game_id: game_id} do
      assert :ok = GameServer.remove_player(game_id, "foobar")
    end
  end

  describe ".reset_dice/1" do
    test "resets roll results, dice counts and dice selections", %{game_id: game_id} do
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
    test "generates new dice results and updates roll counts", %{game_id: game_id} do
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
    test "generates new dice results and updates roll counts", %{game_id: game_id} do
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
    test "updates the dice count for everyone", %{game_id: game_id} do
      assert {:ok, %{dice_count: 5}} = GameServer.set_dice_count(game_id, 5)
    end
  end

  describe ".enter_tokyo/2" do
    test "puts the player in tokyo", %{game_id: game_id} do
      %{id: player_id} = player = Player.new("Jane", :the_king)
      :ok = GameServer.add_player(game_id, player)

      assert :ok = GameServer.enter_tokyo(game_id, player_id)

      assert {:ok, %{tokyo_city_player_id: ^player_id, tokyo_bay_player_id: nil}} =
               GameServer.get_tokyo_state(game_id)
    end
  end

  describe ".leave_tokyo/2" do
    test "removes the player from tokyo", %{game_id: game_id} do
      %{id: player_id} = player = Player.new("Jane", :the_king)
      :ok = GameServer.add_player(game_id, player)

      assert :ok = GameServer.enter_tokyo(game_id, player_id)
      assert :ok = GameServer.leave_tokyo(game_id, player_id)

      assert {:ok, %{tokyo_city_player_id: nil, tokyo_bay_player_id: nil}} =
               GameServer.get_tokyo_state(game_id)
    end
  end

  describe "get_game/1" do
    test "returns the game if found", %{game_id: game_id} do
      assert {:ok, %Game{}} = GameServer.get_game(game_id)
    end

    test "returns an error if game not found" do
      %{game_id: game_id} = GameCode.new()

      assert {:error, :game_not_found} = GameServer.get_game(game_id)
    end
  end

  describe "send_chat_message/2" do
    test "adds the message to the list of messages", %{game_id: game_id} do
      message1 =
        KingOfTokyo.ChatMessage.new(
          "You're crushing Tokyo dude!",
          Player.new("Jenna", :giga_zaur)
        )

      message2 =
        KingOfTokyo.ChatMessage.new(
          "Going for the attack!",
          Player.new("Jay", :kraken)
        )

      assert :ok = GameServer.add_chat_message(game_id, message1)
      assert :ok = GameServer.add_chat_message(game_id, message2)
      assert {:ok, %Game{chat_messages: [message2, message1]}} = GameServer.get_game(game_id)
    end
  end

  describe "get_player_by_id/2" do
    test "returns the player if found", %{game_id: game_id} do
      %{id: player_id} = player = Player.new("Jane", :the_king)
      :ok = GameServer.add_player(game_id, player)

      assert {:ok, ^player} = GameServer.get_player_by_id(game_id, player_id)
    end

    test "returns an error if player not found", %{game_id: game_id} do
      player_id = UUID.uuid4()

      assert {:error, :player_not_found} = GameServer.get_player_by_id(game_id, player_id)
    end

    test "returns an error if game not found" do
      %{game_id: game_id} = GameCode.new()
      %{id: player_id} = Player.new("Jane", :the_king)

      assert {:error, :game_not_found} = GameServer.get_player_by_id(game_id, player_id)
    end
  end
end
