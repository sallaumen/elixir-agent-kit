defmodule Mix.Tasks.AgentKit.Uninstall do
  use Mix.Task
  @shortdoc "Remove only unmodified kit-owned content"
  @moduledoc """
  Remove only unmodified kit-owned content.

      mix agent_kit.uninstall

  Removes every file and block recorded in `.elixir-agent-kit/state.tsv` when it is
  unmodified, restores pre-existing instruction files, and prunes only directories
  it emptied. Takes `--dry-run`; selection flags are refused because uninstall is
  not partial. No task starts your application or calls a model.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:uninstall, args)
end
