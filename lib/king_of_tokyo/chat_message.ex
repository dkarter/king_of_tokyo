defmodule KingOfTokyo.ChatMessage do
  @moduledoc """
  Represents a in-game chat message
  """

  defstruct [:id, :body, :player_id, :sent_at]

  @type t :: %__MODULE__{
          id: String.t(),
          body: String.t(),
          player_id: String.t(),
          sent_at: DateTime.t()
        }

  @spec new(String.t(), String.t()) :: t()
  def new(body, player_id) do
    %__MODULE__{
      id: UUID.uuid4(),
      body: body,
      player_id: player_id,
      sent_at: DateTime.utc_now()
    }
  end

  @spec chunked_message_list(list(t())) :: list(list(t()))
  def chunked_message_list(messages) do
    messages
    |> Enum.chunk_by(&Map.get(&1, :player_id))
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse()
  end
end
