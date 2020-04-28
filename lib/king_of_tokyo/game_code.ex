defmodule KingOfTokyo.GameCode do
  @moduledoc """
  Generates easy game codes for use in connecting players to the same game
  """

  defstruct [:game_code, :game_id]

  @type t :: %__MODULE__{
          game_code: String.t(),
          game_id: String.t()
        }

  @spec new(String.t()) :: t()
  def new(game_code) do
    struct!(__MODULE__, game_code: game_code, game_id: to_game_id(game_code))
  end

  @spec new() :: t()
  def new, do: new(generate_game_code())

  @spec generate_game_code() :: String.t()
  def generate_game_code do
    Ecto.UUID.generate()
    |> String.slice(0..5)
    |> String.upcase()
    |> String.split_at(3)
    |> Tuple.to_list()
    |> Enum.join("-")
  end

  @spec to_game_id(String.t()) :: String.t()
  defp to_game_id(game_code) do
    game_code =
      game_code
      |> String.replace("-", "")
      |> String.downcase()

    "game:#{game_code}"
  end
end
