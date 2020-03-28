defmodule KingOfTokyo.DiceTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.Dice

  describe ".roll/1" do
    test "generate random numbers within allowed range for selected count" do
      %{roll_result: result} =
        Dice.new()
        |> Dice.set_dice_count(6)
        |> Dice.roll()


      assert length(result) == 6
      assert Enum.all?(result, fn res -> res > 0 && res < 7 end)
    end
  end

  describe ".re_roll/2" do
    test "does not shuffle selected dice" do
      dice =
        %{roll_result: [r0, r1, _, _, _, r5]} =
        Dice.new()
        |> Dice.set_dice_count(6)
        |> Dice.roll()
        |> Dice.toggle_selected_dice_index([5, 1, 0])

      assert %{roll_result: [^r0, ^r1, _, _, _, ^r5]} = Dice.re_roll(dice)
    end
  end

  describe ".toggle_selected_dice_index/2" do
    test "removes an index from the list if present" do
      dice = %Dice{selected_roll_results: [1, 4, 2]}
      assert %{selected_roll_results: [1, 2]} = Dice.toggle_selected_dice_index(dice, 4)
    end

    test "adds an index to the list if not present" do
      dice = %Dice{selected_roll_results: [1, 4, 2]}
      assert %{selected_roll_results: [3, 1, 4, 2]} = Dice.toggle_selected_dice_index(dice, 3)
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
