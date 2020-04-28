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
        <div class="player <%= if in_tokyo_city?(player.id, assigns), do: "tokyo-city" %>">
          <div>Name: <%= player.name %></div>
          <div>Character: <%= Player.character_name(player) %></div>
          <div class="row">
            <div class="column">❤️: <%= player.health %></div>
            <div class="column">⭐️: <%= player.points %></div>
            <div class="column">⚡️: <%= player.energy %></div>
          </div>
          <%= if in_tokyo_city?(player.id, assigns) do %>
            <div class="row">
              <div class="column">
                In Tokyo City
              </div>
            </div>
          <% end %>

          <%= if in_tokyo_bay?(player.id, assigns) do %>
            <div class="row">
              <div class="column">
                In Tokyo Bay
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </aside>
    """
  end

  defp in_tokyo_city?(player_id, %{tokyo_city_player_id: player_id}), do: true
  defp in_tokyo_city?(_, _), do: false

  defp in_tokyo_bay?(player_id, %{tokyo_bay_player_id: player_id}), do: true
  defp in_tokyo_bay?(_, _), do: false
end
