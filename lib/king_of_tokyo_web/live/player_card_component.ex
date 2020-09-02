defmodule KingOfTokyoWeb.PlayerCardComponent do
  @moduledoc """
  Form for updating current player's attributes
  """

  use KingOfTokyoWeb, :live_component

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

    ~L"""
    <div class="player-card">
      <form id="<%= form_id %>" action="#" phx-change="update-player" phx-target="#<%= form_id %>">
        <div class="row">
          <div class="column">Name: <input name="name" type="text" value="<%= @player.name %>" /></div>
        </div>
        <div class="stats">
          <div><img src="/images/hearts.svg" class="health" /><input name="health" type="number" min="0" max="12" value="<%= @player.health %>" /></div>
          <div><img src="/images/victory.svg" class="points" /><input name="points" type="number" min="0" max="20" value="<%= @player.points %>" /></div>
          <div><img src="/images/lightning.svg" class="energy" /><input name="energy" type="number" min="0" max="99" value="<%= @player.energy %>" /></div>
          <div>
            <button type="button" class="button button-outline<%= if @in_tokyo, do: " button-danger" %>" phx-click="toggle-tokyo" phx-target="#<%= form_id %>">
              <%= tokyo_button_text(assigns) %>
            </button>
          </div>
        </div>
      </form>
    </div>
    """
  end

  defp tokyo_button_text(%{in_tokyo: true}), do: "Leave Tokyo"
  defp tokyo_button_text(_), do: "Enter Tokyo"
end
