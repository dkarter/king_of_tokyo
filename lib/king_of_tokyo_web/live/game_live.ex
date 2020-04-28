defmodule KingOfTokyoWeb.GameLive do
  @moduledoc """
  LiveView implementation of King Of Tokyo
  """

  use Phoenix.LiveView, layout: {KingOfTokyoWeb.LayoutView, "live.html"}

  alias KingOfTokyo.GameServer
  alias KingOfTokyoWeb.DiceRollerComponent
  alias KingOfTokyoWeb.LobbyLive
  alias KingOfTokyoWeb.PlayerCardComponent
  alias KingOfTokyoWeb.PlayerListComponent
  alias KingOfTokyoWeb.Presence
  alias KingOfTokyoWeb.Router.Helpers, as: Routes

  # alias KingOfTokyoWeb.Router.Helpers, as: Routes

  def handle_info(%{event: "tokyo_updated", payload: tokyo_state}, socket) do
    %{game: game} = socket.assigns

    {:noreply,
     assign(socket,
       game: %{
         game
         | tokyo_city_player_id: tokyo_state.tokyo_city_player_id,
           tokyo_bay_player_id: tokyo_state.tokyo_bay_player_id
       }
     )}
  end

  def handle_info(%{event: "dice_updated", payload: dice_state}, socket) do
    %{game: game} = socket.assigns
    {:noreply, assign(socket, game: %{game | dice_state: dice_state})}
  end

  def handle_info(%{event: "players_updated", payload: _}, socket) do
    %{game: game} = socket.assigns
    game_id = game_id(socket)

    {:ok, players} = GameServer.list_players(game_id)
    presence_player_ids = GameServer.presence_player_ids(game_id)

    players = Enum.filter(players, fn %{id: id} -> id in presence_player_ids end)

    {:noreply, assign(socket, game: %{game | players: players})}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    game_id = game_id(socket)

    # payload.leaves
    # |> Enum.each(fn {player_id, _} ->
    #   :ok = GameServer.mark_offline(game_id, player_id)
    # end)
    KingOfTokyoWeb.Endpoint.broadcast!(game_id, "players_updated", %{})

    {:noreply, socket}
  end

  def handle_info({:put_temporary_flash, level, message}, socket) do
    {:noreply, put_temporary_flash(socket, level, message)}
  end

  def handle_info(:toggle_tokyo, socket) do
    game_id = game_id(socket)

    player = socket.assigns.player

    :ok =
      if in_tokyo?(player.id, socket.assigns) do
        GameServer.leave_tokyo(game_id, player.id)
      else
        GameServer.enter_tokyo(game_id, player.id)
      end

    {:noreply, socket}
  end

  def handle_info({:clear_flash, level}, socket) do
    {:noreply, clear_flash(socket, Atom.to_string(level))}
  end

  def handle_info({:update_player, player}, socket) do
    :ok =
      socket
      |> game_id()
      |> GameServer.update_player(player)

    {:noreply, assign(socket, player: player)}
  end

  def handle_info(:reset_dice, socket) do
    {:ok, _dice_state} =
      socket
      |> game_id()
      |> GameServer.reset_dice()

    {:noreply, socket}
  end

  def handle_info(:roll, socket) do
    {:ok, _dice_state} =
      socket
      |> game_id()
      |> GameServer.roll_dice()

    {:noreply, socket}
  end

  def handle_info(:re_roll, socket) do
    {:ok, _dice_state} =
      socket
      |> game_id()
      |> GameServer.re_roll_dice()

    {:noreply, socket}
  end

  def handle_info({:set_dice_count, count}, socket) do
    {:ok, _dice_state} =
      socket
      |> game_id()
      |> GameServer.set_dice_count(count)

    {:noreply, socket}
  end

  def handle_info({:toggle_selected_dice_index, index}, socket) do
    {:ok, _dice_state} =
      socket
      |> game_id()
      |> GameServer.toggle_selected_dice_index(index)

    {:noreply, socket}
  end

  def handle_info({:update_selected_roll_results, selected_roll_results}, socket) do
    dice_state = Map.put(socket.assigns.dice_state, :selected_roll_results, selected_roll_results)
    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info(:reset_dice_state, socket) do
    socket
    |> game_id()
    |> GameServer.reset_dice()

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="game-container">
      <div class="main-panel">
        <%= live_component(@socket, PlayerCardComponent, id: :my_player_card, player: @player, in_tokyo: in_tokyo?(@player.id, assigns)) %>
        <%= live_component(@socket, DiceRollerComponent, id: :dice_roller, dice_state: @game.dice_state) %>
      </div>
      <%= live_component(@socket, PlayerListComponent, players: @game.players, tokyo_city_player_id: @game.tokyo_city_player_id, tokyo_bay_player_id: @game.tokyo_bay_player_id) %>
    </div>
    """
  end

  def mount(_params, session, socket) do
    socket =
      with %{"game_id" => game_id, "player_id" => player_id} <- session,
           {:ok, game} <- GameServer.get_game(game_id),
           {:ok, player} <- GameServer.get_player_by_id(game_id, player_id),
           {:ok, _} <- Presence.track(self(), game_id, player_id, %{}),
           :ok <- KingOfTokyoWeb.Endpoint.subscribe(game_id) do
        assign(socket, game: game, player: player)
      else
        _ ->
          params =
            if Map.has_key?(session, "game_code") do
              Map.take(session, ["game_code"])
            else
              []
            end

          lobby_path = Routes.live_path(socket, LobbyLive, params)
          push_redirect(socket, to: lobby_path)
      end

    {:ok, socket}
  end

  defp put_temporary_flash(socket, level, message) do
    :timer.send_after(:timer.seconds(3), {:clear_flash, level})

    put_flash(socket, level, message)
  end

  defp in_tokyo?(player_id, %{game: game}) do
    game.tokyo_city_player_id == player_id || game.tokyo_bay_player_id == player_id
  end

  defp game_id(socket) do
    socket.assigns.game.code.game_id
  end
end
