defmodule KingOfTokyoWeb.LayoutView do
  use KingOfTokyoWeb, :view

  import Plug.Conn, only: [get_session: 2]

  def in_game?(conn) do
    in_path? = conn.request_path == Routes.game_path(conn, :index)
    session = get_session(conn, :game_id)

    in_path? && not is_nil(session)
  end
end
