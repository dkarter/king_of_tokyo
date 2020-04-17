defmodule KingOfTokyoWeb.PlayerCardComponent do
  @moduledoc """
  Form for updating current player's attributes
  """

  use Phoenix.LiveComponent

  alias KingOfTokyo.Player

  def handle_event("update-player", fields, socket) do
    %{"name" => name, "health" => health, "points" => points, "energy" => energy} = fields

    player =
      socket.assigns.player
      |> Player.set_name(name)
      |> Player.set_health(health)
      |> Player.set_points(points)
      |> Player.set_energy(energy)

    send(self(), {:update_player, player})

    {:noreply, socket}
  end

  def render(assigns) do
    form_id = "player-card-form-#{assigns.id}"

    ~L"""
    <div class="player-card">
      <form id="<%= form_id %>" action="#" phx-change="update-player" phx-target="#<%= form_id %>">
        <div>Name: <input name="name" type="text" value="<%= @player.name %>" /></div>
        <div>❤️: <input name="health" type="number" min="0" max="12" value="<%= @player.health %>" /></div>
        <div>⭐️: <input name="points" type="number" min="0" max="20" value="<%= @player.points %>" /></div>
        <div>⚡️: <input name="energy" type="number" min="0" value="<%= @player.energy %>" /></div>
      </form>
    </div>
    """
  end
end
