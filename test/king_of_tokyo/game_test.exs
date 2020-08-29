defmodule KingOfTokyo.GameTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.ChatMessage
  alias KingOfTokyo.Game
  alias KingOfTokyo.Player

  describe "add_player/2" do
    test "adds a new player to the game" do
      game = Game.new()

      assert {:ok, %{players: players} = game} =
               Game.add_player(game, Player.new("Joe", :the_king))

      assert length(players) == 1
      assert [%Player{name: "Joe"}] = players
      assert {:ok, %{players: players}} = Game.add_player(game, Player.new("Jane", :giga_zaur))
      assert length(players) == 2
      assert [%Player{name: "Jane"}, %Player{name: "Joe"}] = players
    end

    test "returns an error if player with the same name already exists" do
      game = Game.new() |> Map.put(:players, [Player.new("juan", :giga_zaur)])
      assert {:error, :name_taken} = Game.add_player(game, Player.new("Juan", :the_king))
    end

    test "returns an error if player with the same character already exists" do
      {:ok, game} =
        Game.new()
        |> Game.add_player(Player.new("Mufasa", :the_king))

      assert {:error, :character_taken} = Game.add_player(game, Player.new("Simba", :the_king))
    end
  end

  describe "update_player/2" do
    test "updates a player from the game" do
      game = Game.new()
      player = Player.new("Joe", :the_king)
      {:ok, game} = Game.add_player(game, player)
      updated_player = Map.put(player, :name, "Joseph")
      assert {:ok, %{players: players}} = Game.update_player(game, updated_player)
      assert [%Player{name: "Joseph", character: :the_king}] = players
    end

    test "returns an error if player does not exist" do
      game = Game.new()
      player = Player.new("Joe", :the_king)
      assert {:error, :player_not_found} = Game.update_player(game, player)
    end
  end

  describe "remove_player/2" do
    test "removes a player from the game" do
      game = Game.new()
      player1 = Player.new("Joe", :the_king)
      player2 = Player.new("Jane", :giga_zaur)
      {:ok, game} = Game.add_player(game, player1)
      {:ok, game} = Game.add_player(game, player2)
      assert {:ok, %{players: players}} = Game.remove_player(game, player2.id)
      assert length(players) == 1
      assert [%Player{name: "Joe"}] = players
    end

    test "returns the game unchanged if player does not exist" do
      game = Game.new()
      player = Player.new("Joe", :the_king)
      {:ok, game} = Game.add_player(game, player)
      assert {:ok, ^game} = Game.remove_player(game, "foobar")
    end
  end

  describe "enter_tokyo/2 with less than 4 players" do
    test "marks player is in Tokyo City if no one is in Tokyo City" do
      game = game_with_players(2)

      assert %{tokyo_city_player_id: "p1"} = Game.enter_tokyo(game, "p1")
    end

    test "replaces player in Tokyo City with provided player if less than 5 players in the game" do
      game = game_with_players(2)
      game = Game.enter_tokyo(game, "p1")

      assert %{tokyo_city_player_id: "p2"} = Game.enter_tokyo(game, "p2")
    end
  end

  describe "enter_tokyo/2 with more than 4 players" do
    test "marks player is in Tokyo Bay if Tokyo City is occupied and more than 4 players in game" do
      game = game_with_players(5)
      game = Game.enter_tokyo(game, "p1")

      assert %{tokyo_city_player_id: "p1", tokyo_bay_player_id: "p5"} =
               Game.enter_tokyo(game, "p5")
    end

    test "Promotes player in Tokyo Bay to Tokyo City and puts provided player in Tokyo Bay" do
      game = game_with_players(5)
      game = Game.enter_tokyo(game, "p1")
      game = Game.enter_tokyo(game, "p2")

      assert %{tokyo_city_player_id: "p2", tokyo_bay_player_id: "p5"} =
               Game.enter_tokyo(game, "p5")
    end
  end

  describe "leave_tokyo/2 with less than 4 players" do
    test "removes the player from Tokyo City" do
      game = game_with_players(2)
      game = Game.enter_tokyo(game, "p1")

      assert %{tokyo_city_player_id: nil} = Game.leave_tokyo(game, "p1")
    end

    test "does nothing when player is not in Tokyo City" do
      game = game_with_players(2)
      game = Game.enter_tokyo(game, "p2")

      assert %{tokyo_city_player_id: "p2"} = Game.leave_tokyo(game, "p1")
    end
  end

  describe "leave_tokyo/2 with more than 4 players" do
    test "removes the player from Tokyo Bay" do
      game = game_with_players(5)
      game = Game.enter_tokyo(game, "p2")
      game = Game.enter_tokyo(game, "p4")

      assert %{tokyo_city_player_id: "p2", tokyo_bay_player_id: nil} =
               Game.leave_tokyo(game, "p4")
    end

    test "removes the player from Tokyo City and promotes Tokyo Bay" do
      game = game_with_players(5)
      game = Game.enter_tokyo(game, "p2")
      game = Game.enter_tokyo(game, "p4")

      assert %{tokyo_city_player_id: "p4", tokyo_bay_player_id: nil} =
               Game.leave_tokyo(game, "p2")
    end

    test "does nothing when player is neither in Tokyo City nor Tokyo Bay" do
      game = game_with_players(5)
      game = Game.enter_tokyo(game, "p2")
      game = Game.enter_tokyo(game, "p4")

      assert %{tokyo_city_player_id: "p2", tokyo_bay_player_id: "p4"} =
               Game.leave_tokyo(game, "p5")
    end
  end

  describe "add_chat_message/3" do
    test "adds the new chat message to the game struct" do
      %{id: player_id} = player = Player.new("Joe", :the_king)
      {:ok, game} = Game.add_player(Game.new(), player)
      message = ChatMessage.new("Hi everyone!", player_id)

      assert %Game{chat_messages: [^message]} = Game.add_chat_message(game, message)
    end
  end

  def game_with_players(player_count) do
    1..player_count
    |> Enum.reduce(Game.new(), fn index, game ->
      player_id = "p#{index}"

      character =
        Player.characters()
        |> Map.keys()
        |> Enum.at(index - 1)

      player =
        player_id
        |> Player.new(character)
        |> Map.put(:id, player_id)

      {:ok, game} = Game.add_player(game, player)
      game
    end)
  end
end
