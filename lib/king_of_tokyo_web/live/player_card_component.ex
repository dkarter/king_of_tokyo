defmodule KingOfTokyoWeb.PlayerCardComponent do
  use Phoenix.LiveComponent

  def handle_event("update-player", fields, socket) do
    %{"name" => name, "hearts" => hearts, "stars" => stars} = fields
    player = %{name: name, hearts: String.to_integer(hearts), stars: String.to_integer(stars)}

    send(self(), {:update_player, player})

    {:noreply, socket}
  end

  def render(assigns) do
    form_id = "player-card-form-#{assigns.id}"

    ~L"""
    <div class="player-card">
      <form id="<%= form_id %>" action="#" phx-change="update-player" phx-target="#<%= form_id %>">
        <div>Name: <input name="name" type="text" value="<%= @player.name %>" /></div>
        <div>Hearts: <input name="hearts" type="number" min="0" max="15" value="<%= @player.hearts %>" /></div>
        <div>Stars: <input name="stars" type="number" min="0" max="20" value="<%= @player.stars %>" /></div>
      </form>
    </div>
    """
  end
end
