defmodule KingOfTokyo.Player do
  @moduledoc """
  Represents a player in king of tokyo
  """

  defstruct [
    :character,
    :id,
    :name,
    counters: %{mimic: 0, poison: 0, shrink: 0, smoke: 0},
    health: 10,
    points: 0,
    energy: 0
  ]

  @characters %{
    the_king: "The King",
    cyber_bunny: "Cyber Bunny",
    cyber_kitty: "Cyber Kitty",
    space_pinguin: "Space Pinguin",
    meka_dragon: "Meka Dragon",
    kraken: "Kraken",
    giga_zaur: "Giga Zaur",
    alienoid: "Alienoid"
  }

  @max_points 20
  @max_health 12
  @max_energy 99

  @type character_type ::
          :the_king
          | :cyber_bunny
          | :cyber_kitty
          | :space_pinguin
          | :meka_dragon
          | :kraken
          | :giga_zaur
          | :alienoid

  @type t :: %__MODULE__{
          character: character_type(),
          counters: %{
            mimic: non_neg_integer(),
            poison: non_neg_integer(),
            shrink: non_neg_integer(),
            smoke: non_neg_integer()
          },
          health: integer(),
          id: String.t(),
          energy: non_neg_integer(),
          name: String.t(),
          points: integer()
        }

  @spec new(String.t(), character_type()) :: t()
  def new(name, character) do
    params = %{
      id: UUID.uuid4(),
      name: name,
      character: character
    }

    struct!(__MODULE__, params)
  end

  @spec set_name(t(), String.t()) :: t()
  def set_name(%__MODULE__{} = player, name) do
    name = String.trim(name)

    if name == "" do
      player
    else
      Map.put(player, :name, name)
    end
  end

  @spec set_health(t(), String.t() | integer()) :: t()
  def set_health(%__MODULE__{} = player, ""), do: player

  def set_health(%__MODULE__{} = player, health) when is_binary(health) do
    set_health(player, String.to_integer(health))
  end

  def set_health(%__MODULE__{} = player, health) when health > @max_health do
    set_health(player, @max_health)
  end

  def set_health(%__MODULE__{} = player, health) when health < 0 do
    set_health(player, 0)
  end

  def set_health(%__MODULE__{} = player, health) do
    Map.put(player, :health, health)
  end

  @spec set_energy(t(), String.t() | integer()) :: t()
  def set_energy(%__MODULE__{} = player, ""), do: player

  def set_energy(%__MODULE__{} = player, energy) when is_binary(energy) do
    set_energy(player, String.to_integer(energy))
  end

  def set_energy(%__MODULE__{} = player, energy) when energy > @max_energy do
    set_energy(player, @max_energy)
  end

  def set_energy(%__MODULE__{} = player, energy) when energy < 0 do
    set_energy(player, 0)
  end

  def set_energy(%__MODULE__{} = player, energy) do
    Map.put(player, :energy, energy)
  end

  @spec set_points(t(), String.t() | integer()) :: t()
  def set_points(%__MODULE__{} = player, ""), do: player

  def set_points(%__MODULE__{} = player, points) when is_binary(points) do
    set_points(player, String.to_integer(points))
  end

  def set_points(%__MODULE__{} = player, points) when points > @max_points do
    set_points(player, @max_points)
  end

  def set_points(%__MODULE__{} = player, points) when points < 0 do
    set_points(player, 0)
  end

  def set_points(%__MODULE__{} = player, points) do
    Map.put(player, :points, points)
  end

  def character_name(%__MODULE__{} = player) do
    @characters[player.character]
  end

  def characters, do: @characters
end
