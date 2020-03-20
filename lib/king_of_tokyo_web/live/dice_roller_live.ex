defmodule KingOfTokyoWeb.DiceRollerLive do
  use Phoenix.LiveView

  @dice %{
    1 => %{name: "one"},
    2 => %{name: "two"},
    3 => %{name: "three"},
    4 => %{name: "lightning"},
    5 => %{name: "claw"},
    6 => %{name: "heart"}
  }

  def handle_event("update-player", fields, socket) do
    %{"name" => name, "hearts" => hearts, "stars" => stars} = fields
    {:noreply, assign(socket, name: name, hearts: hearts, stars: stars)}
  end

  def handle_event("toggle-dice", %{"dice-index" => dice_index}, socket) do
    current_selected_results = socket.assigns.selected_roll_results
    dice_index = String.to_integer(dice_index)

    selected_roll_results =
      if Enum.member?(current_selected_results, dice_index) do
        Enum.reject(current_selected_results, &(&1 == dice_index))
      else
        [dice_index | current_selected_results]
      end

    {:noreply, assign(socket, selected_roll_results: selected_roll_results)}
  end

  def handle_event("clear-roll", _, socket) do
    {:noreply, assign(socket, roll_result: [], selected_roll_results: [])}
  end

  def handle_event("re-roll", _, socket) do
    %{roll_result: roll_result, selected_roll_results: selected_roll_results} = socket.assigns

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

    socket = assign(socket, roll_result: roll_result)

    {:noreply, socket}
  end

  def handle_event("roll", %{"dice_count" => dice_count}, socket) do
    roll_result =
      1..String.to_integer(dice_count)
      |> Enum.map(fn _ -> roll_die() end)

    socket = assign(socket, dice_count: dice_count, roll_result: roll_result)

    {:noreply, socket}
  end

  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, roll_result: [], selected_roll_results: [])}
  end

  def render_die(assigns, {value, index}) do
    die = @dice[value]

    color = if index in [6, 7], do: "green", else: "black"

    selected = if Enum.member?(assigns.selected_roll_results, index), do: "selected", else: nil

    classes =
      [
        "die",
        die.name,
        color,
        selected
      ]
      |> Enum.reject(&is_nil(&1))

    ~L"""
    <div class="<%= Enum.join(classes, " ") %>" phx-click="toggle-dice" phx-value-dice-index="<%= index %>"></div>
    """
  end

  def render_dice(assigns) do
    results_with_index = assigns.roll_result |> Enum.with_index()

    ~L"""
    <div class="dice">
      <%= for {value, index} <- results_with_index do %>
        <%= render_die(assigns, {value, index}) %>
      <% end %>
    </div>
    """
  end

  def render_reset_button(assigns) do
    has_results = length(assigns.roll_result) > 0
    disabled = if has_results, do: "", else: "disabled"

    ~L"""
    <button type="reset" class="button danger" <%= disabled %> phx-click="reset">Reset</button>
    """
  end

  def render(assigns) do
    has_results = length(assigns.roll_result) > 0
    roll_action = if has_results, do: "re-roll", else: "roll"
    dice_count_input_disabled = if has_results, do: "disabled", else: ""

    ~L"""
    <div class="player-card">
      <form action="#" phx-change="update-player">
        <div>Name: <input name="name" type="text" value="<%= @name %>" /></div>
        <div>Hearts: <input name="hearts" type="number" min="0" max="15" value="<%= @hearts %>" /></div>
        <div>Stars: <input name="stars" type="number" min="0" max="20" value="<%= @stars %>" /></div>
      </form>
    </div>
    <div class="dice-roll">
      <form action="#" phx-submit="<%= roll_action %>">
        <input type="number" <%= dice_count_input_disabled %> min="1" max="8" name="dice_count" placeholder="How many dice?" value="<%= @dice_count %>" />
        <button type="submit"><%= roll_action %></button>
        <%= render_reset_button(assigns) %>
      </form>
      <%= render_dice(assigns) %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    name = "#{Faker.Name.En.first_name()} #{Faker.Name.En.last_name()}"

    {:ok,
     assign(socket,
       name: name,
       dice_count: 6,
       roll_result: [],
       selected_roll_results: [],
       hearts: 10,
       stars: 0
     )}
  end

  defp roll_die do
    Enum.random(1..6)
  end
end
