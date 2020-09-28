defmodule KingOfTokyoWeb.ChatComponent do
  @moduledoc """
  Displays the chat history and allows sending new messages
  """

  use KingOfTokyoWeb, :live_component

  @impl true
  def handle_event("toggle-chat", _, socket) do
    {:noreply, assign(socket, open: !socket.assigns[:open])}
  end

  @doc """
  Dismisses chat if overlay is clicked - noop if already closed
  """
  @impl true
  def handle_event("dismiss-chat", _, socket) do
    socket =
      if socket.assigns[:open] do
        assign(socket, open: false)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("window-keyup", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, open: false)}
  end

  @impl true
  def handle_event("window-keyup", _event, socket), do: {:noreply, socket}

  @impl true
  def handle_event("window-keydown", %{"code" => "KeyC", "ctrlKey" => true}, socket) do
    {:noreply, assign(socket, open: !socket.assigns[:open])}
  end

  @impl true
  def handle_event("window-keydown", _event, socket), do: {:noreply, socket}

  @impl true
  def mount(socket) do
    {:ok, assign(socket, body: "")}
  end

  @impl true
  def render(assigns) do
    visible_class = if assigns[:open], do: "visible"

    messages =
      assigns.messages
      |> KingOfTokyo.ChatMessage.chunked_message_list()

    ~L"""
    <div id="<%= @id %>"
      class="chat-container <%= visible_class %>"
      phx-capture-click="dismiss-chat"
      phx-target="#<%= @id %>"
      phx-window-keyup="window-keyup"
      phx-window-keydown="window-keydown"
    >
      <button class="chat-button" phx-click="toggle-chat" phx-target="#<%= @id %>">
        <img src="images/chat.svg" />
      </button>
      <%= if assigns[:open] do %>
        <div class="chat-popover <%= visible_class %>">
          <div id="chat-history" class="history" phx-hook="ChatHistory">
            <%= for message_group <- messages do %>
              <%= render_message_group(assigns, message_group) %>
            <% end %>
          </div>
          <%= live_component(@socket, KingOfTokyoWeb.Live.ChatForm, id: :chat_form) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_message_group(assigns, message_group) do
    [first_message | _] = message_group
    from_me = first_message.player_id == assigns.current_player.id

    sender_initials =
      assigns.players
      |> Enum.find(fn %{id: id} -> id == first_message.player_id end)
      |> sender_initials()

    ~L"""
    <div
      id="message-group-<%= first_message.id %>"
      class="message-group <%= if from_me, do: "from-me" %>"
    >
      <div id="messages-<%= first_message.id %>" class="messages">
        <%= for message <- message_group do %>
          <%= render_message_body(assigns, message) %>
        <% end %>
      </div>
      <div class="sender">
        <%= sender_initials %>
      </div>
    </div>
    """
  end

  def render_message_body(assigns, message) do
    body_lines = split_lines(message.body)

    ~L"""
    <div id="chat-msg-<%= message.id %>" class="body">
      <%= for line <- body_lines do %>
        <%= line %>
        <br />
      <% end %>
    </div>
    """
  end

  defp split_lines(str) do
    str
    |> String.trim()
    |> String.split("\n")
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
