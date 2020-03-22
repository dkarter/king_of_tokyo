defmodule KingOfTokyo.Dice do
  @moduledoc """
  Handles everything related to King of Tokyo dice rolling and results,
  including selecting which results to keep and which to re-roll
  """

  @dice %{
    1 => %{name: "one"},
    2 => %{name: "two"},
    3 => %{name: "three"},
    4 => %{name: "lightning"},
    5 => %{name: "claw"},
    6 => %{name: "heart"}
  }

  @spec roll(non_neg_integer()) :: list(pos_integer())
  def roll(count) when count < 1, do: roll(1)
  def roll(count) when count > 8, do: roll(8)

  def roll(count) do
    1..count
    |> Enum.map(fn _ -> roll_die() end)
  end

  @spec re_roll(list(pos_integer()), list(non_neg_integer())) :: list(pos_integer())
  def re_roll(results, selected_result_indices) do
    results
    |> Enum.with_index()
    |> Enum.map(fn {result, index} ->
      if Enum.member?(selected_result_indices, index) do
        result
      else
        roll_die()
      end
    end)
  end

  def toggle_selected_dice_index(selected_results_indices, index) do
    if Enum.member?(selected_results_indices, index) do
      Enum.reject(selected_results_indices, &(&1 == index))
    else
      [index | selected_results_indices]
    end
  end

  @spec name(pos_integer()) :: String.t()
  def name(value) do
    @dice[value].name
  end

  defp roll_die do
    Enum.random(1..6)
  end
end
