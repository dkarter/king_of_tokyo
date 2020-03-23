defmodule KingOfTokyoWeb.KingOfTokyoLive do
  @moduledoc """
  LiveView implementation of King Of Tokyo
  """

  use Phoenix.LiveView

  alias KingOfTokyo.GameCode
  alias KingOfTokyo.Player
  alias KingOfTokyoWeb.DiceRollerComponent
  alias KingOfTokyoWeb.LobbyComponent
  alias KingOfTokyoWeb.PlayerCardComponent
  alias KingOfTokyoWeb.PlayerListComponent
  alias KingOfTokyoWeb.Presence

  def handle_info(%{event: "presence_diff"}, socket) do
    topic = GameCode.to_topic(socket.assigns.code)

    players =
      Presence.list(topic)
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    {:noreply, assign(socket, players: players)}
  end

  def handle_info({:join_game, code: code, player_name: player_name}, socket) do
    player = Player.new(player_name, :the_king)
    topic = GameCode.to_topic(code)

    KingOfTokyoWeb.Endpoint.subscribe(topic)

    {:ok, _} = Presence.track(self(), topic, player.id, player)

    {:noreply, assign(socket, code: code, player: player)}
  end

  def handle_info({:update_player, player}, socket) do
    {:noreply, assign(socket, player: player)}
  end

  def handle_info({:update_roll_result, roll_result}, socket) do
    dice_state =
      socket.assigns.dice_state
      |> Map.put(:roll_result, roll_result)
      |> Map.update!(:roll_count, fn count -> count + 1 end)

    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info({:update_selected_roll_results, selected_roll_results}, socket) do
    dice_state = Map.put(socket.assigns.dice_state, :selected_roll_results, selected_roll_results)
    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info(:reset_dice_state, socket) do
    {:noreply, assign(socket, dice_state: initial_dice_state())}
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
    dice_state = initial_dice_state()
    {:ok, assign(socket, dice_state: dice_state, player: nil, players: [], code: nil)}
  end

  defp initial_dice_state do
    %{
      roll_result: [],
      selected_roll_results: [],
      roll_count: 0
    }
  end

  defp joined?(%{code: nil}), do: false
  defp joined?(%{code: _}), do: true
end
