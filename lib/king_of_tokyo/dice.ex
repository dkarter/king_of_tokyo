defmodule KingOfTokyo.Dice do
  @moduledoc """
  Handles everything related to King of Tokyo dice rolling and results,
  including selecting which results to keep and which to re-roll
  """

  @dice %{
    1 => %{name: "one"},
    2 => %{name: "two"},
    3 => %{name: "three"},
    4 => %{name: "energy"},
    5 => %{name: "claw"},
    6 => %{name: "heart"}
  }

  defstruct dice_count: 6,
            roll_count: 0,
            roll_result: [],
            selected_roll_results: []

  @type t() :: %__MODULE__{
          dice_count: pos_integer(),
          roll_count: pos_integer(),
          roll_result: list(integer()),
          selected_roll_results: list(integer())
        }

  @spec new() :: t()
  def new do
    struct!(__MODULE__)
  end

  @spec roll(t()) :: t()
  def roll(%__MODULE__{} = dice) do
    roll_result =
      1..dice.dice_count
      |> Enum.map(fn _ -> roll_die() end)

    dice
    |> Map.put(:roll_result, roll_result)
    |> increment_roll_count()
  end

  @spec re_roll(t()) :: t()
  def re_roll(%__MODULE__{} = dice) do
    result =
      dice.roll_result
      |> Enum.with_index()
      |> Enum.map(fn {result, index} ->
        if Enum.member?(dice.selected_roll_results, index) do
          result
        else
          roll_die()
        end
      end)

    dice
    |> Map.put(:roll_result, result)
    |> increment_roll_count()
  end

  @spec set_dice_count(t(), non_neg_integer() | String.t()) :: t()
  def set_dice_count(%__MODULE__{} = dice, count) when is_binary(count) do
    set_dice_count(dice, String.to_integer(count))
  end

  def set_dice_count(%__MODULE__{} = dice, count) do
    %{dice | dice_count: count}
  end

  @spec toggle_selected_dice_index(t(), non_neg_integer() | [non_neg_integer()] | String.t()) ::
          t()
  def toggle_selected_dice_index(%__MODULE__{} = dice, index) when is_binary(index) do
    toggle_selected_dice_index(dice, String.to_integer(index))
  end

  def toggle_selected_dice_index(%__MODULE__{} = dice, indexes) when is_list(indexes) do
    Enum.reduce(indexes, dice, fn index, dice ->
      toggle_selected_dice_index(dice, index)
    end)
  end

  def toggle_selected_dice_index(%__MODULE__{} = dice, index) do
    selected_roll_results = dice.selected_roll_results

    selected_roll_results =
      if Enum.member?(selected_roll_results, index) do
        Enum.reject(selected_roll_results, &(&1 == index))
      else
        [index | selected_roll_results]
      end

    %{dice | selected_roll_results: selected_roll_results}
  end

  @spec name(pos_integer()) :: String.t()
  def name(value) do
    @dice[value].name
  end

  defp roll_die do
    Enum.random(1..6)
  end

  defp increment_roll_count(%__MODULE__{} = dice) do
    dice
    |> Map.update!(:roll_count, &(&1 + 1))
  end
end
