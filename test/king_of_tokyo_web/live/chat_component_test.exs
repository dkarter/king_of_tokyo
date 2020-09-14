defmodule KingOfTokyo.ChatComponentTest do
  use KingOfTokyoWeb.ConnCase

  import Phoenix.LiveViewTest

  @endpoint KingOfTokyoWeb.Endpoint

  @subject KingOfTokyoWeb.ChatComponent

  test "renders chat messages" do
    player1 = KingOfTokyo.Player.new("Carl Sagan", :giga_zaur)
    player2 = KingOfTokyo.Player.new("Ann Druyan", :cyber_bunny)
    msg1 = KingOfTokyo.ChatMessage.new("Hi Ann!", player1.id)
    msg2 = KingOfTokyo.ChatMessage.new("Hi Carl!", player2.id)

    html =
      render_component(@subject,
        id: :chat,
        open: true,
        messages: [msg1, msg2],
        current_player: player1,
        players: [player1, player2]
      )

    assert message_text(html, :from_me) == "Hi Ann!"
    assert player_initials(html, :from_me) == "CS"
    assert message_text(html) == "Hi Carl!"
    assert player_initials(html) == "AD"
  end

  defp message_text(html), do: message_text(html, ":not(.from-me)")

  defp message_text(html, :from_me), do: message_text(html, ".from-me")

  defp message_text(html, from_me_selector) do
    html
    |> Floki.parse_document!()
    |> Floki.find(".message-group#{from_me_selector} .body")
    |> Floki.text()
    |> String.trim()
  end

  defp player_initials(html), do: player_initials(html, ":not(.from-me)")

  defp player_initials(html, :from_me), do: player_initials(html, ".from-me")

  defp player_initials(html, from_me_selector) do
    html
    |> Floki.parse_document!()
    |> Floki.find(".message-group#{from_me_selector} .sender")
    |> Floki.text()
    |> String.trim()
  end
end
