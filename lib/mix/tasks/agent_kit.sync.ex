defmodule Mix.Tasks.AgentKit.Sync do
  use Mix.Task
  @shortdoc "Sync the selected package version while preserving local instructions"
  @moduledoc """
  Sync the selected package version while preserving local instructions.

      mix agent_kit.sync

  Configuration is read from `:elixir_agent_kit` in `Mix.Project.config/0`.
  `--agents codex,claude,generic` and `--skills ID,ID` override configuration.
  Mutation tasks accept `--dry-run`. No task starts your application or calls a model.
  See the package README for conflict recovery and client compatibility limits.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:sync, args)
end
