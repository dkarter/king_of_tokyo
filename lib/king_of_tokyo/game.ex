defmodule KingOfTokyo.Game do
  @moduledoc """
  Represents the game structure and exposes actions that can be taken to update
  it
  """

  alias KingOfTokyo.Dice
  alias KingOfTokyo.Player

  defstruct code: nil,
            players: [],
            dice_state: %Dice{},
            tokyo_city_player_id: nil,
            tokyo_bay_player_id: nil

  @type t() :: %__MODULE__{
          players: list(Player.t()),
          dice_state: Dice.t(),
          code: String.t() | nil,
          tokyo_city_player_id: String.t() | nil,
          tokyo_bay_player_id: String.t() | nil
        }

  def new(code \\ nil) do
    %__MODULE__{code: code}
  end

  @doc """
  Adds a new player to the game if one with a similar name does not exist
  """
  @spec add_player(t(), Player.t()) :: {:ok, t()} | {:error, :name_taken | :character_taken}
  def add_player(game, player) do
    %{name: name, character: character} = player

    case find_player(game, %{name: {:case_insensitive, name}, character: character}, match: :any) do
      nil ->
        {:ok, Map.update!(game, :players, &[player | &1])}

      %Player{character: ^character} ->
        {:error, :character_taken}

      %Player{} ->
        {:error, :name_taken}
    end
  end

  @doc """
  Updates a player's data
  """
  @spec update_player(t(), Player.t()) :: {:ok, t()} | {:error, :player_not_found}
  def update_player(game, player) do
    case get_player_by_id(game, player.id) do
      {:ok, _} ->
        game = Map.update!(game, :players, &update_player_by_id(&1, player))

        {:ok, game}

      {:error, :player_not_found} = error ->
        error
    end
  end

  @doc """
  Removes a player with a given id
  """
  @spec remove_player(t(), String.t()) :: {:ok, t()}
  def remove_player(game, player_id) do
    case get_player_by_id(game, player_id) do
      {:ok, _} ->
        game = Map.update!(game, :players, &Enum.reject(&1, fn %{id: id} -> id == player_id end))
        {:ok, game}

      {:error, :player_not_found} ->
        {:ok, game}
    end
  end

  @doc """
  Returns a full list of players in the game
  """
  @spec list_players(t()) :: list(Player.t())
  def list_players(game), do: game.players

  def reset_dice(game) do
    %{game | dice_state: Dice.new()}
  end

  @doc """
  Moves the player to Tokyo City or Tokyo Bay
  """
  @spec enter_tokyo(t(), String.t()) :: t()
  def enter_tokyo(%{players: players} = game, player_id) when length(players) < 5 do
    %{game | tokyo_city_player_id: player_id}
  end

  def enter_tokyo(%{tokyo_city_player_id: nil} = game, player_id) do
    %{game | tokyo_city_player_id: player_id}
  end

  def enter_tokyo(%{tokyo_bay_player_id: nil} = game, player_id) do
    %{game | tokyo_bay_player_id: player_id}
  end

  def enter_tokyo(game, player_id) do
    %{game | tokyo_city_player_id: game.tokyo_bay_player_id, tokyo_bay_player_id: player_id}
  end

  @doc """
  Moves the player out of Tokyo City or Tokyo Bay
  """
  @spec leave_tokyo(t(), String.t()) :: t()
  def leave_tokyo(%{players: players} = game, player_id) when length(players) < 5 do
    if game.tokyo_city_player_id == player_id do
      %{game | tokyo_city_player_id: nil}
    else
      game
    end
  end

  def leave_tokyo(%{tokyo_city_player_id: player_id, tokyo_bay_player_id: nil} = game, player_id) do
    %{game | tokyo_city_player_id: nil}
  end

  def leave_tokyo(
        %{tokyo_city_player_id: <<_::binary>>, tokyo_bay_player_id: player_id} = game,
        player_id
      ) do
    %{game | tokyo_bay_player_id: nil}
  end

  def leave_tokyo(
        %{tokyo_city_player_id: player_id, tokyo_bay_player_id: tokyo_bay_player_id} = game,
        player_id
      ) do
    %{game | tokyo_city_player_id: tokyo_bay_player_id, tokyo_bay_player_id: nil}
  end

  def leave_tokyo(game, _player_id) do
    game
  end

  defp find_player(game, %{} = attrs, match: :any) do
    game.players
    |> Enum.find(fn player ->
      Enum.any?(attrs, &has_equal_attribute?(player, &1))
    end)
  end

  defp find_player(game, %{} = attrs) do
    game.players
    |> Enum.find(fn player ->
      Enum.all?(attrs, &has_equal_attribute?(player, &1))
    end)
  end

  defp has_equal_attribute?(%{} = map, {key, {:case_insensitive, value}}) when is_binary(value) do
    String.downcase(Map.get(map, key, "")) == String.downcase(value)
  end

  defp has_equal_attribute?(%{} = map, {key, value}) do
    Map.get(map, key) == value
  end

  defp get_player_by_id(game, player_id) do
    case find_player(game, %{id: player_id}) do
      %Player{} = player -> {:ok, player}
      nil -> {:error, :player_not_found}
    end
  end

  defp update_player_by_id(players, player) do
    Enum.map(players, fn %{id: id} = original_player ->
      if id == player.id do
        player
      else
        original_player
      end
    end)
  end
end
