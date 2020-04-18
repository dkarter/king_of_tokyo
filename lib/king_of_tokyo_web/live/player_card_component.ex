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

  def handle_event("toggle-tokyo", _, socket) do
    send(self(), :toggle_tokyo)

    {:noreply, socket}
  end

  def render(assigns) do
    form_id = "player-card-form-#{assigns.id}"

    tokyo_button_text = if assigns.in_tokyo, do: "Leave Tokyo", else: "Enter Tokyo"

    ~L"""
    <div class="player-card">
      <form id="<%= form_id %>" action="#" phx-change="update-player" phx-target="#<%= form_id %>">
        <div class="row">
          <div class="column">Name: <input name="name" type="text" value="<%= @player.name %>" /></div>
        </div>
        <div class="row">
          <div class="column">❤️  <input name="health" type="number" min="0" max="12" value="<%= @player.health %>" /></div>
          <div class="column">⭐️ <input name="points" type="number" min="0" max="20" value="<%= @player.points %>" /></div>
          <div class="column">⚡️ <input name="energy" type="number" min="0" value="<%= @player.energy %>" /></div>
          <div class="column"><button type="button" phx-click="toggle-tokyo" phx-target="#<%= form_id %>"><%= tokyo_button_text %></button></div>
        </div>
      </form>
    </div>
    """
  end
end
