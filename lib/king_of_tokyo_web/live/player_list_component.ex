defmodule KingOfTokyoWeb.PlayerListComponent do
  @moduledoc """
  Displays all players' stats
  """

  use KingOfTokyoWeb, :live_component

  alias KingOfTokyo.Player

  def render(assigns) do
    ~L"""
    <aside id="player-list">
      <%= for player <- @players do %>
        <div class="player <%= if in_tokyo_city?(player.id, assigns), do: "tokyo-city" %>">

          <div class="character"><%= Player.character_name(player) %></div>
          <div class="player-name"><%= player.name %></div>
          <div class="stats">
            <div class="column"><img src="/images/hearts.svg" /><span><%= player.health %></span></div>
            <div class="column"><img src="/images/victory.svg" /><span><%= player.points %></span></div>
            <div class="column"><img src="/images/lightning.svg" /><span><%= player.energy %></span></div>
          </div>
          <div class="tokyo-status">
            <%= if in_tokyo_city?(player.id, assigns) do %>
              In Tokyo City
            <% end %>
            <%= if in_tokyo_bay?(player.id, assigns) do %>
              In Tokyo Bay
            <% end %>
          </div>
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
