defmodule KingOfTokyoWeb.GameController do
  use KingOfTokyoWeb, :controller

  def join(conn, params) do
    %{"game_code" => game_code, "game_id" => game_id, "player_id" => player_id} = params

    game_path = Routes.game_path(conn, :index, game_code: game_code)

    conn
    |> put_session(:game_id, game_id)
    |> put_session(:player_id, player_id)
    |> redirect(to: game_path)
  end

  def leave(conn, _params) do
    lobby_path = Routes.live_path(conn, KingOfTokyoWeb.LobbyLive)

    conn
    |> clear_session()
    |> redirect(to: lobby_path)
  end

  def index(conn, %{"game_code" => game_code}) do
    conn
    |> put_session(:game_code, game_code)
    |> live_render(KingOfTokyoWeb.GameLive)
  end
end
