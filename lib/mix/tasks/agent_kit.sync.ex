defmodule Mix.Tasks.AgentKit.Sync do
  use Mix.Task
  @shortdoc "Sync the selected package version while preserving local instructions"
  @moduledoc """
  Sync the selected package version while preserving local instructions.

      mix agent_kit.sync

  Regenerates every owned file and block for the loaded package version, removes
  unmodified legacy generated files, and refuses to touch locally modified managed
  content. Configuration is read from `:elixir_agent_kit` in `Mix.Project.config/0`;
  when that entry exists it is the source of truth, otherwise the recorded selection
  in `.elixir-agent-kit/state.tsv` is kept. `--agents codex,claude,generic` and
  `--skills ID,ID` override it for one run; `--dry-run` lists the paths without
  writing. No task starts your application or calls a model.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:sync, args)
end
