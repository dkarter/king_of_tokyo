defmodule KingOfTokyoWeb.Router do
  use KingOfTokyoWeb, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KingOfTokyoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :basic_auth,
      username: Application.get_env(:king_of_tokyo, :admin_username),
      password: Application.get_env(:king_of_tokyo, :admin_password)
  end

  scope "/", KingOfTokyoWeb do
    pipe_through :browser

    live("/", LobbyLive)
    get("/join_game", GameController, :join)
    get("/game", GameController, :index)
  end

  scope "/admin" do
    pipe_through [:browser, :admin]
    live_dashboard "/dashboard", metrics: KingOfTokyoWeb.Telemetry
  end
end
