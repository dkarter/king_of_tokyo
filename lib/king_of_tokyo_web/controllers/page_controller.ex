defmodule KingOfTokyoWeb.PageController do
  use KingOfTokyoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
