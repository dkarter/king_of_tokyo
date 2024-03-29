defmodule KingOfTokyo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: KingOfTokyo.PubSub},
      # Start the endpoint when the application starts
      KingOfTokyoWeb.Endpoint,
      {Registry, keys: :unique, name: KingOfTokyo.GameRegistry},
      KingOfTokyoWeb.Presence,
      KingOfTokyo.GameSupervisor,
      KingOfTokyo.GameGarbageCollector,
      # Start the Telemetry supervisor
      KingOfTokyoWeb.Telemetry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KingOfTokyo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KingOfTokyoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
