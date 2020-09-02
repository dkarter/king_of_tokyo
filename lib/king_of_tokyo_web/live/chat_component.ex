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
  def handle_event("toggle-chat", _, socket) do
    socket = assign(socket, open: !socket.assigns[:open])
    {:noreply, socket}
  end

  @impl true
  def handle_event("textarea-keypress", %{"key" => "Enter", "shiftKey" => false} = e, socket) do
    send(self(), {:send_message, e["value"]})

    {:noreply, assign(socket, body: "")}
  end

  def handle_event("textarea-keypress", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, open: false)}
  end

  @impl true
  def handle_event("textarea-keypress", _event, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("message-form-updated", %{"body" => body}, socket) do
    {:noreply, assign(socket, body: body)}
  end

  def handle_event("window-keyup", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, open: false)}
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, body: "")}
  end

  @impl true
  def render(assigns) do
    form_id = "chat-message-form-#{assigns.id}"
    messages = assigns.messages |> Enum.reverse() |> Enum.with_index()

    visible_class = if assigns[:open], do: "visible"

    ~L"""
    <div id="<%= @id %>" phx-target="#<%= @id %>" phx-window-keyup="window-keyup">
      <button class="chat-button" phx-click="toggle-chat" phx-target="#<%= @id %>">
        <img src="images/chat.svg" />
      </button>
      <div class="chat-container <%= visible_class %>">
        <div id="chat-history" class="history" phx-hook="ChatHistory" phx-update="append">
          <%= for {message, index} <- messages do %>
            <%= render_message(assigns, message, index) %>
          <% end %>
        </div>
        <form id="<%= form_id %>" action="#" phx-change="message-form-updated" phx-submit="send-message" phx-target="#<%= form_id %>">
          <textarea id="chat-form-textarea" placeholder="Start typing..." name="body" data-pending-val="<%= @body %>" phx-hook="ChatFormTextArea" phx-keyup="textarea-keypress" phx-target="#<%= @id %>"></textarea>
          <button type="submit"><img src="/images/send.svg" /></button>
        </form>
      </div>
    </div>
    """
  end

  defp render_message(assigns, message, index) do
    from_me = message.player_id == assigns.current_player.id

    sender_initials =
      assigns.players
      |> Enum.find(fn %{id: id} -> id == message.player_id end)
      |> sender_initials()

    body_lines =
      message.body
      |> String.trim()
      |> String.split("\n")

    ~L"""
    <div id="chat-msg-<%= index %>" class="message <%= if from_me, do: "from-me" %>">
      <div class="body">
        <%= for line <- body_lines do %>
          <%= line %>
          <br />
        <% end %>
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
