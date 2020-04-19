defmodule KingOfTokyoWeb.Router do
  use KingOfTokyoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {KingOfTokyoWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KingOfTokyoWeb do
    pipe_through :browser

    live("/", LobbyLive)
    get("/join_game", GameController, :join)
    get("/game", GameController, :index)
  end
end
