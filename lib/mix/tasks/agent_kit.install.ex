defmodule Mix.Tasks.AgentKit.Install do
  use Mix.Task
  @shortdoc "Install project-local agent guidance without overwriting unmanaged content"
  @moduledoc """
  Install project-local agent guidance without overwriting unmanaged content.

      mix agent_kit.install

  Same reconciliation as `mix agent_kit.sync`. Configuration is read from
  `:elixir_agent_kit` in `Mix.Project.config/0`; when that entry exists it is the
  source of truth, otherwise the recorded selection in `.elixir-agent-kit/state.tsv`
  is kept. `--agents codex,claude,generic` and `--skills ID,ID` override it for one
  run; `--dry-run` lists the paths without writing. Fails when the dependency's
  library is incomplete. No task starts your application or calls a model.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:install, args)
end
