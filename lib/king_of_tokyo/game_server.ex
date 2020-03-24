defmodule KingOfTokyo.GameServer do
  @moduledoc """
  Holds state for a game and exposes an interface to managing the game instance
  """

  use GenServer

  alias KingOfTokyo.Game

  def start_link(game_name) do
    GenServer.start(__MODULE__, nil, name: via_tuple(game_name))
  end

  def via_tuple(game_name) do
    {:via, Registry, {KingOfTokyo.GameRegistry, game_name}}
  end

  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def add_player(game_name, player) do
    with :ok <- call_by_name(game_name, {:add_player, player}) do
      broadcast_players_updated!(game_name)
    end
  end

  def update_player(game_name, player) do
    with :ok <- call_by_name(game_name, {:update_player, player}) do
      broadcast_players_updated!(game_name)
    end
  end

  def remove_player(game_name, player_id) do
    with :ok <- call_by_name(game_name, {:remove_player, player_id}) do
      broadcast_players_updated!(game_name)
    end
  end

  def list_players(game_name) do
    call_by_name(game_name, :list_players)
  end

  @impl GenServer
  def init(nil) do
    {:ok, %{game: Game.new()}}
  end

  @impl GenServer
  def handle_call({:add_player, player}, _from, state) do
    case Game.add_player(state.game, player) do
      {:ok, game} ->
        {:reply, :ok, %{state | game: game}}

      {:error, :name_taken} = error ->
        {:reply, error, state}
    end
  end

  @impl GenServer
  def handle_call({:update_player, player}, _from, state) do
    case Game.update_player(state.game, player) do
      {:ok, game} ->
        {:reply, :ok, %{state | game: game}}

      {:error, :player_not_found} = error ->
        {:reply, error, state}
    end
  end

  @impl GenServer
  def handle_call({:remove_player, player_id}, _from, state) do
    {:ok, game} = Game.remove_player(state.game, player_id)
    {:reply, :ok, %{state | game: game}}
  end

  @impl GenServer
  def handle_call(:list_players, _from, state) do
    {:reply, {:ok, Game.list_players(state.game)}, state}
  end

  defp call_by_name(game_name, command) do
    case game_pid(game_name) do
      game_pid when is_pid(game_pid) ->
        GenServer.call(game_pid, command)

      nil ->
        {:error, :game_not_found}
    end
  end

  defp broadcast_players_updated!(game_name) do
    KingOfTokyoWeb.Endpoint.broadcast!(game_name, "players_updated", %{})
  end
end
