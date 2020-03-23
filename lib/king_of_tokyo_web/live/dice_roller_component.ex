defmodule KingOfTokyoWeb.DiceRollerComponent do
  @moduledoc """
  Interface for rolling the King Of Tokyo Dice
  """

  use Phoenix.LiveComponent

  alias KingOfTokyo.Dice

  def handle_event("toggle-dice", %{"dice-index" => dice_index}, socket) do
    current_selected_results = socket.assigns.dice_state.selected_roll_results
    dice_index = String.to_integer(dice_index)

    selected_roll_results = Dice.toggle_selected_dice_index(current_selected_results, dice_index)

    send(self(), {:update_selected_roll_results, selected_roll_results})

    {:noreply, socket}
  end

  def handle_event("re-roll", _, socket) do
    %{roll_result: roll_result, selected_roll_results: selected_roll_results} =
      socket.assigns.dice_state

    roll_result = Dice.re_roll(roll_result, selected_roll_results)

    send(self(), {:update_roll_result, roll_result})

    {:noreply, socket}
  end

  def handle_event("roll", %{"dice_count" => dice_count}, socket) do
    roll_result =
      dice_count
      |> String.to_integer()
      |> Dice.roll()

    send(self(), {:update_roll_result, roll_result})

    {:noreply, assign(socket, dice_count: dice_count)}
  end

  def handle_event("reset", _, socket) do
    send(self(), :reset_dice_state)
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
    results_with_index = assigns.dice_state.roll_result |> Enum.with_index()

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
    has_results = length(assigns.dice_state.roll_result) > 0
    roll_action = if has_results, do: "re-roll", else: "roll"
    dice_count_input_disabled = if has_results, do: "disabled", else: ""

    ~L"""
    <div class="dice-roll">
      <form id="<%= @id %>" action="#" phx-submit="<%= roll_action %>" phx-target="#<%= @id %>">
        <input type="number" <%= dice_count_input_disabled %> min="1" max="8" name="dice_count" placeholder="How many dice?" value="<%= @dice_count %>" />
        <button type="submit"><%= roll_action %></button>
        <%= render_reset_button(assigns) %>
      </form>
      <%= render_dice(assigns) %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, dice_count: 6)}
  end
end
