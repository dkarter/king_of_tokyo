defmodule KingOfTokyoWeb.LobbyComponent do
  @moduledoc """
  UI for joining a game room
  """

  use KingOfTokyoWeb, :live_component

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
    %{"game_code" => code, "player_name" => player_name, "character" => character} = fields

    payload = %{
      game_code: code,
      player_name: player_name,
      character: String.to_existing_atom(character)
    }

    send(self(), {:join_game, payload})

    {:noreply, socket}
  end

  def handle_event("update", fields, socket) do
    %{"game_code" => code, "player_name" => player_name, "character" => character} = fields

    socket =
      socket
      |> assign(
        game_code: code,
        player_name: player_name,
        character: String.to_existing_atom(character)
      )

    {:noreply, socket}
  end

  def handle_event("generate-code", _, socket) do
    {:noreply, assign(socket, game_code: GameCode.generate_game_code())}
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
        <section class="player-details">
          <label>
            Player Name:
            <input name="player_name" type="text" value="<%= @player_name %>" />
          </label>
          <%= render_character_select(assigns) %>
        </section>
        <div class="row">
          <div class="column">
            <label>
              Game Code:
              <input name="game_code" type="text" value="<%= @game_code %>"/>
            </label>
          </div>
          <div class="column generate-code-container">
            <button type="button" class="button button-outline" phx-click="generate-code" phx-target="#<%= @id %>">Generate</button>
          </div>
        </div>
        <button type="submit">Join</button>
      </form>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, player_name: "", character: :the_king)}
  end
end
