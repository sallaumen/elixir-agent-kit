defmodule Mix.Tasks.AgentKit.Uninstall do
  use Mix.Task
  @shortdoc "Remove only unmodified kit-owned content"
  @moduledoc """
  Remove only unmodified kit-owned content.

      mix agent_kit.uninstall

  Configuration is read from `:elixir_agent_kit` in `Mix.Project.config/0`.
  `--agents codex,claude,generic` and `--skills ID,ID` override configuration.
  Mutation tasks accept `--dry-run`. No task starts your application or calls a model.
  See the package README for conflict recovery and client compatibility limits.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:uninstall, args)
end
