defmodule KingOfTokyo.LobbyLiveTest do
  use KingOfTokyoWeb.ConnCase

  import Phoenix.LiveViewTest

  @endpoint KingOfTokyoWeb.Endpoint

  setup %{conn: conn} do
    path = Routes.live_path(conn, KingOfTokyoWeb.LobbyLive, [])
    {:ok, view, html} = live(conn, path)
    {:ok, %{view: view, html: html}}
  end

  test "cannot enter a game with no player name", %{view: view} do
    view
    |> form("#lobby form", %{
      "character" => "the_king",
      "game_code" => "VALID_CODE",
      "player_name" => ""
    })
    |> render_submit()

    assert render(view) =~ "name must be at least 2 characters long"
  end

  test "cannot login without code", %{view: view} do
    view
    |> form("#lobby form", %{
      "character" => "the_king",
      "game_code" => "",
      "player_name" => "Jose Valim"
    })
    |> render_submit()

    assert render(view) =~ "code must be at least 2 characters long"
  end

  test "redirects to game when all details have been entered correctly", %{view: view} do
    view
    |> form("#lobby form", %{
      "character" => "the_king",
      "game_code" => "VALID_CODE",
      "player_name" => "Jose Valim"
    })
    |> render_submit()

    assert_receive {_ref, {:redirect, _, %{to: url}}}
    assert url =~ "/join_game?game_id=game%3Avalid_code&game_code=VALID_CODE&player_id="
  end
end
