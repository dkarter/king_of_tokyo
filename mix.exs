defmodule KingOfTokyo.MixProject do
  use Mix.Project

  def project do
    [
      app: :king_of_tokyo,
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      deps: deps(),
      dialyzer: dialyzer(),
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {KingOfTokyo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.3", rutime: false, only: [:dev, :test]},
      {:dialyxir, "~> 1.0", runtime: false, only: [:dev, :test]},
      {:ecto, "~> 3.3"},
      {:excoveralls, "~> 0.12", only: :test},
      {:faker, "~> 0.13"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.4.12"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:edeliver, "~> 1.8.0"},
      {:distillery, "~> 2.1.1"}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      ignore_warnings: ".dialyzer_ignore.exs",
      plt_add_apps: [:mix]
    ]
  end

  defp releases do
    [
      king_of_tokyo: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end
end
