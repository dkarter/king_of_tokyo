defmodule KingOfTokyo.DiceTest do
  use ExUnit.Case

  alias KingOfTokyo.Dice

  describe ".roll/1" do
    test "generate random numbers within allowed range for selected count" do
      results = Dice.roll(5)
      assert length(results) == 5
      assert Enum.all?(results, fn res -> res > 0 && res < 7 end)
    end

    test "will roll at a maximum 8 dice" do
      assert length(Dice.roll(9)) == 8
    end

    test "will roll at a minimum 1 die" do
      assert [res] = Dice.roll(0)
      assert is_integer(res)
    end
  end

  describe ".re_roll/2" do
    test "does not shuffle selected dice" do
      [r0, r1, _, _, _, r5] = results = Dice.roll(6)
      assert [^r0, ^r1, _, _, _, ^r5] = Dice.re_roll(results, [0, 5, 1])
    end
  end

  describe ".toggle_selected_dice_index/2" do
    test "removes an index from the list if present" do
      assert [1, 2] == Dice.toggle_selected_dice_index([1, 4, 2], 4)
    end

    test "adds an index to the list if not present" do
      assert [3, 1, 4, 2] == Dice.toggle_selected_dice_index([1, 4, 2], 3)
    end
  end

  describe ".name/1" do
    test "returns the name of the dice by it's value" do
      assert Dice.name(1) == "one"
      assert Dice.name(5) == "claw"
      assert Dice.name(6) == "heart"
    end
  end
end
