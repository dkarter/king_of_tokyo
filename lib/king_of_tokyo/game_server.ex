defmodule KingOfTokyo.GameServer do
  @moduledoc """
  Holds state for a game and exposes an interface to managing the game instance
  """

  use GenServer

  alias KingOfTokyo.Dice
  alias KingOfTokyo.Game
  alias KingOfTokyo.Player

  require Logger

  @garbage_collection_interval :timer.minutes(5)

  def add_player(game_id, player) do
    with :ok <- call_by_name(game_id, {:add_player, player}) do
      broadcast_players_updated!(game_id)
    end
  end

  @spec get_player_by_id(String.t(), String.t()) ::
          {:ok, Player.t()} | {:error, :game_not_found | :player_not_found}
  def get_player_by_id(game_id, player_id) do
    call_by_name(game_id, {:get_player_by_id, player_id})
  end

  def update_player(game_id, player) do
    with :ok <- call_by_name(game_id, {:update_player, player}) do
      broadcast_players_updated!(game_id)
    end
  end

  def remove_player(game_id, player_id) do
    with :ok <- call_by_name(game_id, {:remove_player, player_id}) do
      broadcast_players_updated!(game_id)
    end
  end

  def list_players(game_id) do
    call_by_name(game_id, :list_players)
  end

  def enter_tokyo(game_id, player_id) do
    with {:ok, tokyo_state} <- call_by_name(game_id, {:enter_tokyo, player_id}) do
      broadcast_tokyo_updated!(game_id, tokyo_state)
    end
  end

  def leave_tokyo(game_id, player_id) do
    with {:ok, tokyo_state} <- call_by_name(game_id, {:leave_tokyo, player_id}) do
      broadcast_tokyo_updated!(game_id, tokyo_state)
    end
  end

  def get_tokyo_state(game_id) do
    call_by_name(game_id, :get_tokyo_state)
  end

  @spec get_game(String.t()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_game(game_id) do
    call_by_name(game_id, :get_game)
  end

  def get_dice_state(game_id) do
    call_by_name(game_id, :get_dice_state)
  end

  def reset_dice(game_id) do
    with {:ok, dice_state} <- call_by_name(game_id, :reset_dice) do
      broadcast_dice_updated!(game_id, dice_state)
      {:ok, dice_state}
    end
  end

  def roll_dice(game_id) do
    with {:ok, dice_state} <- call_by_name(game_id, :roll_dice) do
      broadcast_dice_updated!(game_id, dice_state)
      {:ok, dice_state}
    end
  end

  def re_roll_dice(game_id) do
    with {:ok, dice_state} <- call_by_name(game_id, :re_roll_dice) do
      broadcast_dice_updated!(game_id, dice_state)
      {:ok, dice_state}
    end
  end

  @spec toggle_selected_dice_index(String.t(), integer()) ::
          {:ok, Dice.t()} | {:error, :game_not_found}
  def toggle_selected_dice_index(game_id, index) do
    with {:ok, dice_state} <- call_by_name(game_id, {:toggle_selected_dice_index, index}) do
      broadcast_dice_updated!(game_id, dice_state)
      {:ok, dice_state}
    end
  end

  @spec set_dice_count(String.t(), integer()) :: {:ok, Dice.t()} | {:error, :game_not_found}
  def set_dice_count(game_id, count) do
    with {:ok, dice_state} <- call_by_name(game_id, {:set_dice_count, count}) do
      broadcast_dice_updated!(game_id, dice_state)
      {:ok, dice_state}
    end
  end

  def presence_player_ids(game_id) do
    game_id
    |> KingOfTokyoWeb.Presence.list()
    |> Enum.map(fn {player_id, _} -> player_id end)
  end

  def start_link(game_id) do
    Logger.info("Creating game server for: #{game_id}")
    GenServer.start(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def via_tuple(game_id) do
    {:via, Registry, {KingOfTokyo.GameRegistry, game_id}}
  end

  def game_pid(game_id) do
    game_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  @impl GenServer
  def init(game_code) do
    {:ok, timer} = :timer.send_interval(@garbage_collection_interval, :garbage_collect)
    {:ok, %{game: Game.new(game_code), garbage_collector_timer: timer}}
  end

  @impl GenServer
  def handle_call({:add_player, player}, _from, state) do
    case Game.add_player(state.game, player) do
      {:ok, game} ->
        {:reply, :ok, %{state | game: game}}

      {:error, :name_taken} = error ->
        {:reply, error, state}

      {:error, :character_taken} = error ->
        {:reply, error, state}
    end
  end

  @impl GenServer
  def handle_call({:get_player_by_id, player_id}, _from, state) do
    {:reply, Game.get_player_by_id(state.game, player_id), state}
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

  @impl GenServer
  def handle_call({:enter_tokyo, player_id}, _from, state) do
    game = Game.enter_tokyo(state.game, player_id)
    tokyo_state = Map.take(game, [:tokyo_city_player_id, :tokyo_bay_player_id])
    {:reply, {:ok, tokyo_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_call({:leave_tokyo, player_id}, _from, state) do
    game = Game.leave_tokyo(state.game, player_id)
    tokyo_state = Map.take(game, [:tokyo_city_player_id, :tokyo_bay_player_id])
    {:reply, {:ok, tokyo_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_call(:get_tokyo_state, _from, state) do
    tokyo_state = Map.take(state.game, [:tokyo_city_player_id, :tokyo_bay_player_id])
    {:reply, {:ok, tokyo_state}, state}
  end

  @impl GenServer
  def handle_call(:get_game, _from, state) do
    {:reply, {:ok, state.game}, state}
  end

  @impl GenServer
  def handle_call(:get_dice_state, _from, state) do
    {:reply, {:ok, state.game.dice_state}, state}
  end

  @impl GenServer
  def handle_call(:reset_dice, _from, state) do
    game = Game.reset_dice(state.game)
    {:reply, {:ok, game.dice_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_call(:roll_dice, _from, state) do
    dice_state = Dice.roll(state.game.dice_state)
    game = %{state.game | dice_state: dice_state}
    {:reply, {:ok, dice_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_call(:re_roll_dice, _from, state) do
    dice_state = Dice.re_roll(state.game.dice_state)
    game = %{state.game | dice_state: dice_state}
    {:reply, {:ok, dice_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_call({:toggle_selected_dice_index, index}, _from, state) do
    dice_state = Dice.toggle_selected_dice_index(state.game.dice_state, index)
    game = %{state.game | dice_state: dice_state}
    {:reply, {:ok, dice_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_call({:set_dice_count, count}, _from, state) do
    dice_state = Dice.set_dice_count(state.game.dice_state, count)
    game = %{state.game | dice_state: dice_state}
    {:reply, {:ok, dice_state}, %{state | game: game}}
  end

  @impl GenServer
  def handle_info(:garbage_collect, state) do
    game_id = state.game.code

    Logger.info("Running garbage collection for: #{game_id}")
    presence_player_ids = presence_player_ids(game_id)

    if presence_player_ids == [] do
      Logger.info("No more players present on: #{game_id}, shutting down game server...")
      :timer.cancel(state.garbage_collector_timer)
      KingOfTokyo.GameSupervisor.stop_game(game_id)
    end

    {:noreply, state}
  end

  defp call_by_name(game_id, command) do
    case game_pid(game_id) do
      game_pid when is_pid(game_pid) ->
        GenServer.call(game_pid, command)

      nil ->
        {:error, :game_not_found}
    end
  end

  defp broadcast_dice_updated!(game_id, dice_state) do
    KingOfTokyoWeb.Endpoint.broadcast!(game_id, "dice_updated", dice_state)
  end

  defp broadcast_players_updated!(game_id) do
    KingOfTokyoWeb.Endpoint.broadcast!(game_id, "players_updated", %{})
  end

  defp broadcast_tokyo_updated!(game_id, tokyo_state) do
    KingOfTokyoWeb.Endpoint.broadcast!(game_id, "tokyo_updated", tokyo_state)
  end
end
