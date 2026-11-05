defmodule Mix.Tasks.AgentKit.Install do
  use Mix.Task
  @shortdoc "Install project-local agent guidance without overwriting unmanaged content"
  @moduledoc """
  Install project-local agent guidance without overwriting unmanaged content.

      mix agent_kit.install

  Configuration is read from `:elixir_agent_kit` in `Mix.Project.config/0`.
  `--agents codex,claude,generic` and `--skills ID,ID` override configuration.
  Mutation tasks accept `--dry-run`. No task starts your application or calls a model.
  See the package README for conflict recovery and client compatibility limits.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:install, args)
end
