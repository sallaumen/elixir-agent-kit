defmodule Mix.Tasks.AgentKit.Check do
  use Mix.Task
  @shortdoc "Check installed guidance for drift without writing files"
  @moduledoc """
  Check installed guidance for drift without writing files.

      mix agent_kit.check

  Configuration is read from `:elixir_agent_kit` in `Mix.Project.config/0`.
  `--agents codex,claude,generic` and `--skills ID,ID` override configuration.
  Mutation tasks accept `--dry-run`. No task starts your application or calls a model.
  See the package README for conflict recovery and client compatibility limits.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:check, args)
end
