defmodule KingOfTokyoWeb.PlayerListComponent do
  @moduledoc """
  Displays all players' stats
  """

  use Phoenix.LiveComponent

  alias KingOfTokyo.Player

  def render(assigns) do
    ~L"""
    <aside id="player-list">
      <%= for player <- @players do %>
        <div class="player">
          <div>Name: <%= player.name %></div>
          <div>Character: <%= Player.character_name(player) %></div>
          <div>❤️: <%= player.health %></div>
          <div>⭐️: <%= player.points %></div>
          <div>⚡️: <%= player.lightning %></div>
        </div>
      <% end %>
    </aside>
    """
  end
end
