defmodule KingOfTokyo.ChatMessage do
  @moduledoc """
  Represents a in-game chat message
  """

  defstruct [:body, :player_id, :sent_at]

  @type t :: %__MODULE__{
          body: String.t(),
          player_id: String.t(),
          sent_at: DateTime.t()
        }

  @spec new(String.t(), String.t()) :: t()
  def new(body, player_id) do
    %__MODULE__{
      body: body,
      player_id: player_id,
      sent_at: DateTime.utc_now()
    }
  end
end
