defmodule KingOfTokyoWeb.DiceRollerComponent do
  @moduledoc """
  Interface for rolling the King Of Tokyo Dice
  """

  use Phoenix.LiveComponent

  alias KingOfTokyo.Dice

  def handle_event("toggle-dice", %{"dice-index" => dice_index}, socket) do
    send(self(), {:toggle_selected_dice_index, dice_index})
    {:noreply, socket}
  end

  def handle_event("re-roll", _, socket) do
    send(self(), :re_roll)
    {:noreply, socket}
  end

  def handle_event("roll", _, socket) do
    send(self(), :roll)
    {:noreply, socket}
  end

  def handle_event("update", %{"dice_count" => dice_count}, socket) do
    dice_count = if dice_count == "", do: "0", else: dice_count
    send(self(), {:set_dice_count, dice_count})
    {:noreply, socket}
  end

  def handle_event("reset", _, socket) do
    send(self(), :reset_dice)
    {:noreply, socket}
  end

  def render_die(assigns, {value, index}) do
    die_name = Dice.name(value)

    color = if index in [6, 7], do: "green", else: "black"

    selected =
      if Enum.member?(assigns.dice_state.selected_roll_results, index), do: "selected", else: nil

    classes =
      [
        "die",
        die_name,
        color,
        selected
      ]
      |> Enum.reject(&is_nil(&1))

    ~L"""
    <div class="<%= Enum.join(classes, " ") %>" phx-click="toggle-dice" phx-value-dice-index="<%= index %>" phx-target="#<%= @id %>"></div>
    """
  end

  def render_dice(assigns) do
    results_with_index = Enum.with_index(assigns.dice_state.roll_result)

    ~L"""
    <div class="dice">
      <%= for {value, index} <- results_with_index do %>
        <%= render_die(assigns, {value, index}) %>
      <% end %>
    </div>
    """
  end

  def render_reset_button(assigns) do
    has_results = length(assigns.dice_state.roll_result) > 0
    disabled = if has_results, do: "", else: "disabled"

    ~L"""
    <button type="reset" class="button danger" <%= disabled %> phx-click="reset" phx-target="#<%= @id %>">Reset</button>
    """
  end

  def render(assigns) do
    %{
      dice_state: %{
        roll_result: roll_result,
        roll_count: roll_count,
        dice_count: dice_count
      }
    } = assigns

    has_results = length(roll_result) > 0
    roll_action = if has_results, do: "re-roll", else: "roll"

    ~L"""
    <div class="dice-roll">
      <form id="<%= @id %>" action="#" phx-change="update" phx-submit="<%= roll_action %>" phx-target="#<%= @id %>">
        <label>
          How many dice
          <input type="number" <%= if has_results, do: "disabled" %> min="1" max="8" name="dice_count" placeholder="How many dice?" value="<%= dice_count %>" />
        </label>
        <div class="roll-count">
          <div>Roll Count:</div>
          <div><%= roll_count %></div>
        </div>
        <button type="submit"><%= roll_action %></button>
        <%= render_reset_button(assigns) %>
      </form>
      <%= render_dice(assigns) %>
    </div>
    """
  end
end
