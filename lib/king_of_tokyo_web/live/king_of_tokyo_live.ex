defmodule KingOfTokyoWeb.KingOfTokyoLive do
  use Phoenix.LiveView

  alias KingOfTokyoWeb.PlayerCardComponent
  alias KingOfTokyoWeb.DiceRollerComponent

  def handle_info({:update_player, player}, socket) do
    {:noreply, assign(socket, player: player)}
  end

  def handle_info({:update_roll_result, roll_result}, socket) do
    dice_state = Map.put(socket.assigns.dice_state, :roll_result, roll_result)
    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info({:update_selected_roll_results, selected_roll_results}, socket) do
    dice_state = Map.put(socket.assigns.dice_state, :selected_roll_results, selected_roll_results)
    {:noreply, assign(socket, dice_state: dice_state)}
  end

  def handle_info(:reset_dice_state, socket) do
    {:noreply, assign(socket, dice_state: initial_dice_state())}
  end

  def render(assigns) do
    ~L"""
    <div class="game-container">
      <%= live_component(@socket, PlayerCardComponent, id: :my_player_card, player: @player) %>
      <%= live_component(@socket, DiceRollerComponent, id: :dice_roller, dice_state: @dice_state) %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    dice_state = initial_dice_state()

    player = %{
      name: "#{Faker.Name.En.first_name()} #{Faker.Name.En.last_name()}",
      hearts: 10,
      stars: 0
    }

    {:ok, assign(socket, dice_state: dice_state, player: player)}
  end

  defp initial_dice_state do
    %{
      roll_result: [],
      selected_roll_results: [],
      dice_count: 6
    }
  end
end
