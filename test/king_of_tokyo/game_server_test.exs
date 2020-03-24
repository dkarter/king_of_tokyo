defmodule KingOfTokyo.GameServerTest do
  use ExUnit.Case, async: true

  alias KingOfTokyo.GameServer

  describe ".start_link" do
    test "starts a new game" do
      assert {:ok, pid} = GameServer.start_link(Ecto.UUID.generate())
      assert is_pid(pid)
    end
  end
end
