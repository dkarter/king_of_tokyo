defmodule KingOfTokyo.PlayerTest do
  use ExUnit.Case

  alias KingOfTokyo.Player

  describe ".new/2" do
    test "creates a new player" do
      assert %Player{
               name: "John",
               character: :kraken,
               health: 10,
               points: 0
             } = Player.new("John", :kraken)
    end

    test "creates a new player with a unique id" do
      assert %Player{id: id1} = Player.new("John", :kraken)
      assert %Player{id: id2} = Player.new("John", :kraken)
      refute id1 == id2
    end
  end

  describe ".set_name/2" do
    test "sets a player's namee" do
      assert %{name: "Joe"} = Player.set_name(%Player{}, "Joe")
    end

    test "does not change the name if provided an empty string" do
      assert %{name: "Joe"} = Player.set_name(%Player{name: "Joe"}, "")
      assert %{name: "Joe"} = Player.set_name(%Player{name: "Joe"}, " ")
    end
  end

  describe ".set_points/2" do
    test "sets a player's points" do
      assert %{points: 12} = Player.set_points(%Player{}, 12)
    end

    test "accepts string and turns it into integer" do
      assert %{points: 12} = Player.set_points(%Player{}, "12")
    end

    test "cannot exceed 20" do
      assert %{points: 20} = Player.set_points(%Player{}, 21)
    end

    test "cannot be less than 0" do
      assert %{points: 0} = Player.set_points(%Player{}, -1)
    end
  end

  describe ".set_health/2" do
    test "sets a player's health" do
      assert %{health: 12} = Player.set_health(%Player{}, 12)
    end

    test "accepts string and turns it into integer" do
      assert %{health: 12} = Player.set_health(%Player{}, "12")
    end

    test "cannot exceed 12" do
      assert %{health: 12} = Player.set_health(%Player{}, 13)
    end

    test "cannot be less than 0" do
      assert %{health: 0} = Player.set_health(%Player{}, -1)
    end
  end

  describe ".character_name/1" do
    test "returns a string for character name" do
      assert "The King" == Player.character_name(%Player{character: :the_king})
      assert "Alienoid" == Player.character_name(%Player{character: :alienoid})
    end
  end
end
