defmodule Mix.Tasks.BuildJs do
  use Mix.Task

  @shortdoc """
  Compiles the frontend (via webpack) in production mode
  """

  def run(_args) do
    Mix.shell().cmd("mkdir -p priv/static")
    Mix.shell().cmd("yarn install --cwd assets && yarn --cwd assets deploy")
    Mix.Task.run("phx.digest")
  end
end
