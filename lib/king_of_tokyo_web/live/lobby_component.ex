defmodule KingOfTokyoWeb.LobbyComponent do
  use Phoenix.LiveComponent

  alias KingOfTokyo.GameCode

  def handle_event("join-game", %{"code" => code, "player_name" => player_name}, socket) do
    send(self(), {:join_game, code: code, player_name: player_name})

    {:noreply, socket}
  end

  def handle_event("update", %{"code" => code, "player_name" => player_name}, socket) do
    {:noreply, assign(socket, code: code, player_name: player_name)}
  end

  def handle_event("generate-code", _, socket) do
    {:noreply, assign(socket, code: GameCode.generate())}
  end

  def render(assigns) do
    ~L"""
    <div class="lobby-container">
      <form id="<%= @id %>" phx-change="update" phx-submit="join-game" phx-target="#<%= @id %>">
        <label>
          Player Name:
          <input name="player_name" type="text" value="<%= @player_name %>" />
        </label>
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
    {:ok, assign(socket, code: "", player_name: "")}
  end
end
