defmodule Mix.Tasks.BuildJs do
  @moduledoc """
  Compiles the frontend (via webpack) in production mode
  """
  use Mix.Task

  @shortdoc @moduledoc

  def run(_args) do
    Mix.shell().cmd("mkdir -p priv/static")
    Mix.shell().cmd("yarn install --cwd assets && yarn --cwd assets deploy")
    Mix.Task.run("phx.digest.clean")
    Mix.Task.run("phx.digest")
  end
end
