defmodule KingOfTokyoWeb.ChatComponent do
  @moduledoc """
  Displays the chat history and allows sending new messages
  """

  use KingOfTokyoWeb, :live_component

  @impl true
  def handle_event("send-message", %{"body" => body}, socket) do
    send(self(), {:send_message, body})

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    form_id = "chat-message-form-#{assigns.id}"
    messages = Enum.reverse(assigns.messages)

    ~L"""
    <div class="chat-container">
      <div class="history">
        <%= for message <- messages do %>
          <%= render_message(assigns, message) %>
        <% end %>
      </div>
      <form id="<%= form_id %>" action="#" phx-submit="send-message" phx-target="#<%= form_id %>">
        <textarea name="body"></textarea>
        <button type="submit">Send</button>
      </form>
    </div>
    """
  end

  defp render_message(assigns, message) do
    from_me = message.player_id == assigns.current_player.id

    sender_initials =
      assigns.players
      |> Enum.find(fn %{id: id} -> id == message.player_id end)
      |> sender_initials()

    ~L"""
    <div class="message <%= if from_me, do: "from-me" %>">
      <div class="body">
        <%= message.body %>
      </div>
      <div class="sender">
        <%= sender_initials %>
      </div>
    </div>
    """
  end

  # Extracts the first two initials from a player's name and upcases them
  defp sender_initials(player) do
    player
    |> Map.get(:name)
    |> String.split(" ", trim: true, parts: 2)
    |> Enum.map(fn <<initial::size(8), _rest::binary>> -> initial end)
    |> to_string()
    |> String.upcase()
  end
end
