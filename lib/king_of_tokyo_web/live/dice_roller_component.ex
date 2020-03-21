defmodule KingOfTokyoWeb.DiceRollerComponent do
  use Phoenix.LiveComponent

  @dice %{
    1 => %{name: "one"},
    2 => %{name: "two"},
    3 => %{name: "three"},
    4 => %{name: "lightning"},
    5 => %{name: "claw"},
    6 => %{name: "heart"}
  }

  def handle_event("toggle-dice", %{"dice-index" => dice_index}, socket) do
    current_selected_results = socket.assigns.dice_state.selected_roll_results
    dice_index = String.to_integer(dice_index)

    selected_roll_results =
      if Enum.member?(current_selected_results, dice_index) do
        Enum.reject(current_selected_results, &(&1 == dice_index))
      else
        [dice_index | current_selected_results]
      end

    send(self(), {:update_selected_roll_results, selected_roll_results})

    {:noreply, socket}
  end

  def handle_event("re-roll", _, socket) do
    %{roll_result: roll_result, selected_roll_results: selected_roll_results} =
      socket.assigns.dice_state

    roll_result =
      roll_result
      |> Enum.with_index()
      |> Enum.map(fn {result, index} ->
        if Enum.member?(selected_roll_results, index) do
          result
        else
          roll_die()
        end
      end)

    send(self(), {:update_roll_result, roll_result})

    {:noreply, socket}
  end

  def handle_event("roll", %{"dice_count" => dice_count}, socket) do
    roll_result =
      1..String.to_integer(dice_count)
      |> Enum.map(fn _ -> roll_die() end)

    send(self(), {:update_roll_result, roll_result})

    {:noreply, assign(socket, dice_count: dice_count)}
  end

  def handle_event("reset", _, socket) do
    send(self(), :reset_dice_state)
    {:noreply, socket}
  end

  def render_die(assigns, {value, index}) do
    die = @dice[value]

    color = if index in [6, 7], do: "green", else: "black"

    selected =
      if Enum.member?(assigns.dice_state.selected_roll_results, index), do: "selected", else: nil

    classes =
      [
        "die",
        die.name,
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

  defp roll_die do
    Enum.random(1..6)
  end
end
