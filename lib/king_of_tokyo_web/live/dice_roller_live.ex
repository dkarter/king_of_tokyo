defmodule KingOfTokyoWeb.DiceRollerLive do
  use Phoenix.LiveView

  @dice %{
    1 => %{name: "one", icon: "1️⃣ "},
    2 => %{name: "two", icon: "2️⃣ "},
    3 => %{name: "three", icon: "3️⃣ "},
    4 => %{name: "lightning", icon: "⚡"},
    5 => %{name: "claw", icon: "👊"},
    6 => %{name: "heart", icon: "❤️"}
  }

  def render_die(assigns, {value, index}) do
    die = @dice[value]

    ~L"""
    <div class="die die-<%= die.name %> die-index-<%= index %>"></div>
    """
  end

  def render_dice(assigns) do
    ~L"""
    <div class="dice">
      <%= for {value, index} <- @roll_result do %>
        <%= render_die(assigns, {value, index}) %>
      <% end %>
    </div>
    """
  end

  def render(assigns) do
    ~L"""
    <div class="dice-roll">
      <form action="#" phx-submit="roll">
        <input type="number" min="1" max="8" name="dice_count" placeholder="How many dice?" value="<%= @dice_count %>"/>
        <button type="submit">Roll</button>
      </form>
      <%= render_dice(assigns) %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, dice_count: 6, roll_result: [])}
  end

  def handle_event("roll", %{"dice_count" => dice_count}, socket) do
    roll_result =
      1..String.to_integer(dice_count)
      |> Enum.map(fn _ -> 1..6 |> Enum.random() end)
      |> Enum.with_index(1)

    {:noreply, assign(socket, dice_count: dice_count, roll_result: roll_result)}
  end
end
