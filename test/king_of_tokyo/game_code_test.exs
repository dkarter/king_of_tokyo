defmodule KingOfTokyo.GameCodeTest do
  use ExUnit.Case

  alias KingOfTokyo.GameCode

  describe ".generate/0" do
    test "generates a code" do
      assert String.match?(GameCode.generate(), ~r/^[A-Z0-9]{3}-[A-Z0-9]{3}$/)
    end
  end

  describe ".to_topic/0" do
    test "converts code to topic" do
      assert "game:f00bar" == GameCode.to_topic("F00-BAR")
    end
  end
end
