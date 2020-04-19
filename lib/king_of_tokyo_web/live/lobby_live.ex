defmodule KingOfTokyoWeb.LobbyLive do
  @moduledoc """
  Lobby for joining a game
  """

  use Phoenix.LiveView, layout: {KingOfTokyoWeb.LayoutView, "live.html"}

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
    %{code: code, player_name: player_name, character: character} = attrs

    player = Player.new(player_name, character)
    game_id = GameCode.to_game_id(code)

    KingOfTokyo.GameSupervisor.start_game(game_id)

    socket =
      case GameServer.add_player(game_id, player) do
        :ok ->
          url =
            Routes.game_path(
              socket,
              :join,
              game_id: game_id,
              code: code,
              player_id: player.id
            )

          socket
          |> assign(code: code, player: player)
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
    <%= live_component(@socket, LobbyComponent, id: :lobby, code: @code) %>
    """
  end

  def mount(params, _session, socket) do
    code = Map.get(params, "code", "")
    {:ok, assign(socket, code: code)}
  end

  defp put_temporary_flash(socket, level, message) do
    :timer.send_after(:timer.seconds(3), {:clear_flash, level})

    put_flash(socket, level, message)
  end
end
