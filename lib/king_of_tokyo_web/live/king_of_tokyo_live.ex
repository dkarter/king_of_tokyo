defmodule KingOfTokyoWeb.KingOfTokyoLive do
  @moduledoc """
  LiveView implementation of King Of Tokyo
  """

  use Phoenix.LiveView

  alias KingOfTokyo.GameCode
  alias KingOfTokyo.GameServer
  alias KingOfTokyo.Player
  alias KingOfTokyoWeb.DiceRollerComponent
  alias KingOfTokyoWeb.LobbyComponent
  alias KingOfTokyoWeb.PlayerCardComponent
  alias KingOfTokyoWeb.PlayerListComponent
  alias KingOfTokyoWeb.Presence

  def handle_info(%{event: "dice_updated", payload: dice_state}, socket) do
    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info(%{event: "players_updated", payload: _}, socket) do
    topic = GameCode.to_topic(socket.assigns.code)
    {:ok, players} = GameServer.list_players(topic)
    {:noreply, assign(socket, players: players)}
  end

  def handle_info(%{event: "presence_diff", payload: payload}, socket) do
    topic = GameCode.to_topic(socket.assigns.code)

    payload.leaves
    |> Enum.each(fn {player_id, _} ->
      :ok = GameServer.remove_player(topic, player_id)
    end)

    {:noreply, socket}
  end

  def handle_info({:join_game, code: code, player_name: player_name}, socket) do
    player = Player.new(player_name, :the_king)
    topic = GameCode.to_topic(code)

    KingOfTokyo.GameSupervisor.start_game(topic)

    KingOfTokyoWeb.Endpoint.subscribe(topic)

    :ok = GameServer.add_player(topic, player)

    {:ok, _} = Presence.track(self(), topic, player.id, %{online_at: System.system_time(:second)})

    {:noreply, assign(socket, code: code, player: player)}
  end

  def handle_info({:update_player, player}, socket) do
    :ok =
      socket.assigns.code
      |> GameCode.to_topic()
      |> GameServer.update_player(player)

    {:noreply, assign(socket, player: player)}
  end

  def handle_info(:reset_dice, socket) do
    {:ok, _dice_state} =
      socket.assigns.code
      |> GameCode.to_topic()
      |> GameServer.reset_dice()

    {:noreply, socket}
  end

  def handle_info(:roll, socket) do
    {:ok, _dice_state} =
      socket.assigns.code
      |> GameCode.to_topic()
      |> GameServer.roll_dice()

    {:noreply, socket}
  end

  def handle_info(:re_roll, socket) do
    {:ok, _dice_state} =
      socket.assigns.code
      |> GameCode.to_topic()
      |> GameServer.re_roll_dice()

    {:noreply, socket}
  end

  def handle_info({:set_dice_count, count}, socket) do
    {:ok, _dice_state} =
      socket.assigns.code
      |> GameCode.to_topic()
      |> GameServer.set_dice_count(count)

    {:noreply, socket}
  end

  def handle_info({:toggle_selected_dice_index, index}, socket) do
    {:ok, _dice_state} =
      socket.assigns.code
      |> GameCode.to_topic()
      |> GameServer.toggle_selected_dice_index(index)

    {:noreply, socket}
  end

  def handle_info({:update_selected_roll_results, selected_roll_results}, socket) do
    dice_state = Map.put(socket.assigns.dice_state, :selected_roll_results, selected_roll_results)
    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info(:reset_dice_state, socket) do
    topic = GameCode.to_topic(socket.assigns.code)
    GameServer.reset_dice(topic)
    {:noreply, socket}
  end

  def render(assigns) do
    if joined?(assigns) do
      ~L"""
      <div class="game-container">
        <div class="main-panel">
          <%= live_component(@socket, PlayerCardComponent, id: :my_player_card, player: @player) %>
          <%= live_component(@socket, DiceRollerComponent, id: :dice_roller, dice_state: @dice_state) %>
        </div>
        <%= live_component(@socket, PlayerListComponent, players: @players) %>
      </div>
      """
    else
      ~L"""
      <%= live_component(@socket, LobbyComponent, id: :lobby) %>
      """
    end
  end

  def mount(_params, _session, socket) do
    initial_state =
      KingOfTokyo.Game.new()
      |> Map.put(:player, nil)
      |> Map.to_list()

    {:ok, assign(socket, initial_state)}
  end

  defp joined?(%{code: nil}), do: false
  defp joined?(%{code: _}), do: true
end
