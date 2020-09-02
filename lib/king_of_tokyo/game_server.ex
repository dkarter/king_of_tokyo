defmodule KingOfTokyo.GameServer do
  @moduledoc """
  Holds state for a game and exposes an interface to managing the game instance
  """

  use GenServer

  alias KingOfTokyo.ChatMessage
  alias KingOfTokyo.Dice
  alias KingOfTokyo.Game
  alias KingOfTokyo.GameCode
  alias KingOfTokyo.Player

  require Logger

  @spec add_chat_message(String.t(), ChatMessage.t()) :: :ok
  def add_chat_message(game_id, message) do
    cast_by_name(game_id, {:add_chat_message, message})
  end

  @spec add_player(String.t(), Player.t()) ::
          :ok | {:error, :game_not_found | :name_taken | :character_taken}
  def add_player(game_id, player) do
    with :ok <- call_by_name(game_id, {:add_player, player}) do
      broadcast_players_updated!(game_id)
      :telemetry.execute([:king_of_tokyo, :player_joined], %{count: 1})
    end
  end

  @spec get_player_by_id(String.t(), String.t()) ::
          {:ok, Player.t()} | {:error, :game_not_found | :player_not_found}
  def get_player_by_id(game_id, player_id) do
    call_by_name(game_id, {:get_player_by_id, player_id})
  end

  @spec update_player(String.t(), Player.t()) ::
          :ok | {:error, :game_not_found | :player_not_found}
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

  @spec get_game(String.t() | pid()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_game(pid) when is_pid(pid) do
    GenServer.call(pid, :get_game)
  end

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

  @spec presence_player_ids(String.t()) :: list(String.t())
  def presence_player_ids(game_id) do
    game_id
    |> KingOfTokyoWeb.Presence.list()
    |> Enum.map(fn {player_id, _} -> player_id end)
  end

  def start_link(%GameCode{} = code) do
    GenServer.start(__MODULE__, code, name: via_tuple(code.game_id))
  end

  def game_pid(game_id) do
    game_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  @impl GenServer
  def init(%GameCode{} = code) do
    Logger.info("Creating game server for #{code.game_code} (#{code.game_id})")
    {:ok, %{game: Game.new(code)}}
  end

  @impl GenServer
  def handle_cast({:add_chat_message, message}, state) do
    %{chat_messages: messages} = game = Game.add_chat_message(state.game, message)
    broadcast_chat_updated!(game.code.game_id, messages)
    {:noreply, %{state | game: game}}
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

  @spec broadcast!(String.t(), atom(), map()) :: :ok
  def broadcast!(game_id, event, payload \\ %{}) do
    Phoenix.PubSub.broadcast!(KingOfTokyo.PubSub, game_id, %{event: event, payload: payload})
  end

  defp call_by_name(game_id, command) do
    case game_pid(game_id) do
      game_pid when is_pid(game_pid) ->
        GenServer.call(game_pid, command)

      nil ->
        {:error, :game_not_found}
    end
  end

  defp cast_by_name(game_id, command) do
    case game_pid(game_id) do
      game_pid when is_pid(game_pid) ->
        GenServer.cast(game_pid, command)

      nil ->
        {:error, :game_not_found}
    end
  end

  defp broadcast_chat_updated!(game_id, messages) do
    broadcast!(game_id, :chat_updated, %{messages: messages})
  end

  defp broadcast_dice_updated!(game_id, dice_state) do
    broadcast!(game_id, :dice_updated, dice_state)
  end

  defp broadcast_players_updated!(game_id) do
    broadcast!(game_id, :players_updated)
  end

  defp broadcast_tokyo_updated!(game_id, tokyo_state) do
    broadcast!(game_id, :tokyo_updated, tokyo_state)
  end

  @spec via_tuple(String.t()) :: {:via, atom(), {atom(), String.t()}}
  defp via_tuple(game_id) do
    {:via, Registry, {KingOfTokyo.GameRegistry, game_id}}
  end
end
