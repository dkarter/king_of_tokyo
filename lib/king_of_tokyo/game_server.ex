defmodule KingOfTokyo.GameServer do
  @moduledoc """
  Holds state for a game and exposes an interface to managing the game instance
  """

  use GenServer

  alias KingOfTokyo.Dice
  alias KingOfTokyo.Game

  @garbage_collection_interval :timer.minutes(10)

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

  def get_dice_state(game_name) do
    call_by_name(game_name, :get_dice_state)
  end

  def reset_dice(game_name) do
    with {:ok, dice_state} <- call_by_name(game_name, :reset_dice) do
      broadcast_dice_updated!(game_name, dice_state)
      {:ok, dice_state}
    end
  end

  def roll_dice(game_name) do
    with {:ok, dice_state} <- call_by_name(game_name, :roll_dice) do
      broadcast_dice_updated!(game_name, dice_state)
      {:ok, dice_state}
    end
  end

  def re_roll_dice(game_name) do
    with {:ok, dice_state} <- call_by_name(game_name, :re_roll_dice) do
      broadcast_dice_updated!(game_name, dice_state)
      {:ok, dice_state}
    end
  end

  @spec toggle_selected_dice_index(String.t(), integer()) ::
          {:ok, Dice.t()} | {:error, :game_not_found}
  def toggle_selected_dice_index(game_name, index) do
    with {:ok, dice_state} <- call_by_name(game_name, {:toggle_selected_dice_index, index}) do
      broadcast_dice_updated!(game_name, dice_state)
      {:ok, dice_state}
    end
  end

  @spec set_dice_count(String.t(), integer()) :: {:ok, Dice.t()} | {:error, :game_not_found}
  def set_dice_count(game_name, count) do
    with {:ok, dice_state} <- call_by_name(game_name, {:set_dice_count, count}) do
      broadcast_dice_updated!(game_name, dice_state)
      {:ok, dice_state}
    end
  end

  def start_link(game_name) do
    GenServer.start(__MODULE__, game_name, name: via_tuple(game_name))
  end

  def via_tuple(game_name) do
    {:via, Registry, {KingOfTokyo.GameRegistry, game_name}}
  end

  def game_pid(game_name) do
    game_name
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
    player_ids =
      state.game.code
      |> KingOfTokyoWeb.Presence.list()
      |> Enum.map(fn {player_id, _} -> player_id end)

    if player_ids == [] do
      :timer.cancel(state.garbage_collector_timer)
      KingOfTokyo.GameSupervisor.stop_game(state.game.code)
    end

    {:noreply, state}
  end

  defp call_by_name(game_name, command) do
    case game_pid(game_name) do
      game_pid when is_pid(game_pid) ->
        GenServer.call(game_pid, command)

      nil ->
        {:error, :game_not_found}
    end
  end

  defp broadcast_dice_updated!(game_name, dice_state) do
    KingOfTokyoWeb.Endpoint.broadcast!(game_name, "dice_updated", dice_state)
  end

  defp broadcast_players_updated!(game_name) do
    KingOfTokyoWeb.Endpoint.broadcast!(game_name, "players_updated", %{})
  end
end
