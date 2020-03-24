defmodule KingOfTokyo.Game do
  @moduledoc """
  Represents the game structure and exposes actions that can be taken to update
  it
  """

  alias KingOfTokyo.Player

  defstruct players: []

  @typep t() :: %__MODULE__{
           players: list(Player.t())
         }

  def new do
    %__MODULE__{}
  end

  @doc """
  Adds a new player to the game if one with a similar name does not exist
  """
  @spec add_player(t(), Player.t()) :: {:ok, t()} | {:error, :name_taken}
  def add_player(game, player) do
    case find_player_by_name(game, player.name) do
      nil ->
        {:ok, Map.update!(game, :players, &[player | &1])}

      _ ->
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

  defp find_player_by_name(game, name) do
    game.players
    |> Enum.find(fn player ->
      String.downcase(player.name) == String.downcase(name)
    end)
  end

  defp get_player_by_id(game, player_id) do
    game.players
    |> Enum.find(&(&1.id == player_id))
    |> case do
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
