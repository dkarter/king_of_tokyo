defmodule KingOfTokyoWeb.GameController do
  use KingOfTokyoWeb, :controller

  def join(conn, params) do
    %{"code" => code, "game_id" => game_id, "player_id" => player_id} = params

    url = Routes.game_path(conn, :index, code: code)

    conn
    |> put_session(:game_id, game_id)
    |> put_session(:player_id, player_id)
    |> redirect(to: url)
  end

  def index(conn, %{"code" => code}) do
    conn
    |> put_session(:code, code)
    |> live_render(KingOfTokyoWeb.GameLive)
  end
end
