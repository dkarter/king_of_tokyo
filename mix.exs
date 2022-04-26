defmodule KingOfTokyo.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :king_of_tokyo,
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      deps: deps(),
      dialyzer: dialyzer(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.2.0"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {KingOfTokyo.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
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
      {:distillery, "~> 2.1.1"},
      {:edeliver, "~> 1.8.0"},
      {:elixir_uuid, "~> 1.2"},
      {:excoveralls, "~> 0.12", only: :test},
      {:faker, "~> 0.13"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:phoenix_live_reload, "~> 1.2.1", only: :dev},
      {:phoenix_live_view, "~> 0.14"},
      {:phoenix_pubsub, "~> 2.1"},
      {:plug_cowboy, "~> 2.5"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:logger_file_backend, "~> 0.0.11", only: :prod},
      {:logflare_logger_backend, "~> 0.7", only: :prod}
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

  defp aliases do
    [
      ansible: &run_ansible/1,
      pulumi: &run_pulumi/1
    ]
  end

  defp run_ansible(_) do
    Mix.shell().cmd(
      "cd ansible/ && ANSIBLE_FORCE_COLOR=True ansible-playbook main.yml --vault-password-file .vault-password"
    )
  end

  defp run_pulumi(args) do
    Mix.shell().cmd("cd infra/ && pulumi --color always #{Enum.join(args, " ")}")
  end
end
