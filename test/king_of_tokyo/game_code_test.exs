defmodule KingOfTokyo.GameCodeTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.GameCode

  describe ".new/1" do
    test "returns a game code struct with the game id" do
      assert %GameCode{game_code: "FOO-BAR", game_id: "game:foobar"} == GameCode.new("FOO-BAR")
    end
  end

  describe ".generate/0" do
    test "generates a code" do
      assert String.match?(GameCode.generate_game_code(), ~r/^[A-Z0-9]{3}-[A-Z0-9]{3}$/)
    end
  end
end
