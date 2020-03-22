defmodule KingOfTokyo.GameCode do
  @moduledoc """
  Generates easy game codes for use in connecting players to the same game
  """

  def generate do
    Ecto.UUID.generate()
    |> String.slice(0..5)
    |> String.upcase()
    |> String.split_at(3)
    |> Tuple.to_list()
    |> Enum.join("-")
  end

  def to_topic(code) do
    code =
      code
      |> String.replace("-", "")
      |> String.downcase()

    "game:#{code}"
  end
end
