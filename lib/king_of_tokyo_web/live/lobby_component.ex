defmodule KingOfTokyoWeb.LobbyComponent do
  @moduledoc """
  UI for joining a game room
  """

  use Phoenix.LiveComponent

  alias KingOfTokyo.GameCode
  alias KingOfTokyo.Player

  def handle_event("join-game", %{"code" => code}, socket) when byte_size(code) < 2 do
    send(self(), {:put_temporary_flash, :error, "code must be at least 2 characters long"})
    {:noreply, socket}
  end

  def handle_event("join-game", %{"player_name" => name}, socket) when byte_size(name) < 2 do
    send(self(), {:put_temporary_flash, :error, "name must be at least 2 characters long"})
    {:noreply, socket}
  end

  def handle_event("join-game", fields, socket) do
    %{"code" => code, "player_name" => player_name, "character" => character} = fields

    payload = %{
      code: code,
      player_name: player_name,
      character: String.to_existing_atom(character)
    }

    send(self(), {:join_game, payload})

    {:noreply, socket}
  end

  def handle_event("update", fields, socket) do
    %{"code" => code, "player_name" => player_name, "character" => character} = fields

    socket =
      socket
      |> assign(
        code: code,
        player_name: player_name,
        character: String.to_existing_atom(character)
      )

    {:noreply, socket}
  end

  def handle_event("generate-code", _, socket) do
    {:noreply, assign(socket, code: GameCode.generate())}
  end

  def render_character_select(assigns) do
    ~L"""
    <label>
      <div>Character:</div>
      <select name="character" onchange="this.blur()">
        <%= for {value, name} <- Player.characters() do %>
          <option value="<%= value %>" <%= if value == @character, do: "selected" %>><%= name %></option>
        <% end %>
      </select>
    </label>
    """
  end

  def render(assigns) do
    ~L"""
    <div class="lobby-container">
      <form id="<%= @id %>" phx-change="update" phx-submit="join-game" phx-target="#<%= @id %>">
        <label>
          Player Name:
          <input name="player_name" type="text" value="<%= @player_name %>" />
        </label>
        <%= render_character_select(assigns) %>
        <label>
          Game Code:
          <div class="game-code-field">
            <input name="code" type="text" value="<%= @code %>"/>
            <button type="button" phx-click="generate-code" phx-target="#<%= @id %>">Generate</button>
          </div>
        </label>
        <button type="submit">Join</button>
      </form>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, code: "", player_name: "", character: :the_king)}
  end
end
