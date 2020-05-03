defmodule KingOfTokyoWeb.Telemetry do
  @moduledoc false
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: :timer.seconds(10)}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Game Metrics
      summary("king_of_tokyo.active_players.total"),
      summary("king_of_tokyo.active_games.total")
    ]
  end

  def active_games_count do
    :telemetry.execute([:king_of_tokyo, :active_games], %{
      total: Registry.count(KingOfTokyo.GameRegistry)
    })
  end

  def total_active_players_count do
    count =
      KingOfTokyo.GameSupervisor.which_children()
      |> Enum.reduce(0, fn {_, game_server_pid, _, _}, acc ->
        {:ok, game} = KingOfTokyo.GameServer.get_game(game_server_pid)

        game_id = game.code.game_id

        game_id
        |> KingOfTokyo.GameServer.presence_player_ids()
        |> length()
        |> Kernel.+(acc)
      end)

    :telemetry.execute([:king_of_tokyo, :active_players], %{total: count})
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      {__MODULE__, :active_games_count, []},
      {__MODULE__, :total_active_players_count, []}
    ]
  end
end
