defmodule KingOfTokyoWeb.PlayerListComponent do
  use Phoenix.LiveComponent

  alias KingOfTokyo.Player

  def render(assigns) do
    ~L"""
    <aside id="player-list">
      <%= for player <- @players do %>
        <div class="player">
          <div>Name: <%= player.name %></div>
          <div>Character: <%= Player.character_name(player) %></div>
          <div>Hearts: <%= player.health %></div>
          <div>Stars: <%= player.points %></div>
        </div>
      <% end %>
    </aside>
    """
  end
end
