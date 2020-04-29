defmodule KingOfTokyoWeb.LobbyLive do
  @moduledoc """
  Lobby for joining a game
  """

  use KingOfTokyoWeb, :live_view

  alias KingOfTokyo.GameCode
  alias KingOfTokyo.GameServer
  alias KingOfTokyo.Player
  alias KingOfTokyoWeb.LobbyComponent
  alias KingOfTokyoWeb.Router.Helpers, as: Routes

  def handle_info({:clear_flash, level}, socket) do
    {:noreply, clear_flash(socket, Atom.to_string(level))}
  end

  def handle_info({:put_temporary_flash, level, message}, socket) do
    {:noreply, put_temporary_flash(socket, level, message)}
  end

  def handle_info({:join_game, attrs}, socket) do
    %{game_code: game_code, player_name: player_name, character: character} = attrs

    player = Player.new(player_name, character)
    code = GameCode.new(game_code)

    KingOfTokyo.GameSupervisor.start_game(code)

    socket =
      case GameServer.add_player(code.game_id, player) do
        :ok ->
          url =
            Routes.game_path(
              socket,
              :join,
              game_id: code.game_id,
              game_code: code.game_code,
              player_id: player.id
            )

          socket
          |> put_temporary_flash(:info, "Joined successfully")
          |> push_redirect(to: url)

        {:error, :character_taken} ->
          socket
          |> put_temporary_flash(:error, "Character already taken, choose another")

        {:error, :name_taken} ->
          socket
          |> put_temporary_flash(:error, "Name already taken, please choose a different name")
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <%= live_component(@socket, LobbyComponent, id: :lobby, game_code: @game_code) %>
    """
  end

  def mount(params, _session, socket) do
    code = Map.get(params, "game_code", "")
    {:ok, assign(socket, game_code: code)}
  end

  defp put_temporary_flash(socket, level, message) do
    :timer.send_after(:timer.seconds(3), {:clear_flash, level})

    put_flash(socket, level, message)
  end
end
