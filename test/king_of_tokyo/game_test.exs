defmodule KingOfTokyo.GameTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.Game
  alias KingOfTokyo.Player

  describe ".add_player/2" do
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

  describe ".update_player/2" do
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

  describe ".remove_player/2" do
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
end
