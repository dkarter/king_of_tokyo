defmodule KingOfTokyoWeb.Live.ChatForm do
  @moduledoc """
  Chat Form separated out from the chat popover so that history doesn't get
  resent every time a key is clicked in the chat
  """
  use KingOfTokyoWeb, :live_component

  @impl true
  def handle_event("textarea-keypress", %{"key" => "Enter", "shiftKey" => false} = e, socket) do
    if blank?(e["value"]) do
      {:noreply, socket}
    else
      send(self(), {:send_message, e["value"]})
      {:noreply, assign(socket, body: "")}
    end
  end

  @impl true
  def handle_event("textarea-keypress", %{"key" => "Escape"}, socket) do
    send_update(KingOfTokyoWeb.ChatComponent, id: :chat, open: false)
    {:noreply, assign(socket, open: false)}
  end

  @impl true
  def handle_event("textarea-keypress", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("send-message", %{"body" => body}, socket) do
    send(self(), {:send_message, body})

    {:noreply, socket}
  end

  @impl true
  def handle_event("message-form-updated", %{"body" => body}, socket) do
    {:noreply, assign(socket, body: body)}
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, body: "")}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <form
      action="#"
      phx-change="message-form-updated"
      phx-submit="send-message"
      phx-target="<%= @myself %>"
    >
      <textarea
        id="chat-form-textarea"
        placeholder="Start typing..."
        name="body"
        data-pending-val="<%= @body %>"
        phx-hook="ChatFormTextArea"
        phx-keyup="textarea-keypress"
        phx-target="<%= @myself %>"
        autofocus="true"
      ></textarea>
      <button type="submit" <%= if blank?(assigns[:body]), do: "disabled=\"disabled\"" %>>
        <img src="/images/send.svg" />
      </button>
    </form>
    """
  end

  defp blank?(str) do
    str
    |> to_string()
    |> String.trim()
    |> String.length() == 0
  end
end
