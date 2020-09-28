defmodule KingOfTokyo.ChatMessageTest do
  use ExUnit.Case

  alias KingOfTokyo.ChatMessage

  describe "chunked_message_list/1" do
    test "groups messages by sender if consecutive" do
      messages = [
        m7 = ChatMessage.new("Let's go!", "p1"),
        m6 = ChatMessage.new("I'm connecting the camera", "p2"),
        m5 = ChatMessage.new("Ready to play ;)", "p2"),
        m4 = ChatMessage.new("Wonderful", "p1"),
        m3 = ChatMessage.new("Hi!! yes I'm here", "p2"),
        m2 = ChatMessage.new("Anyone here?", "p1"),
        m1 = ChatMessage.new("Hello!", "p1")
      ]

      assert ChatMessage.chunked_message_list(messages) == [
               [m1, m2],
               [m3],
               [m4],
               [m5, m6],
               [m7]
             ]
    end
  end
end
