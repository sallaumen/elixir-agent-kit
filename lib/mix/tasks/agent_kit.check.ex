defmodule Mix.Tasks.AgentKit.Check do
  use Mix.Task
  @shortdoc "Check installed guidance for drift without writing files"
  @moduledoc """
  Check installed guidance for drift without writing files.

      mix agent_kit.check

  Compares every owned file and block with what the loaded package and the
  configuration would generate, and verifies that the library files the links
  point at exist. Exits nonzero on drift or a missing library. `--agents` and
  `--skills` check against a different selection; it is already read-only, so
  `--dry-run` is refused. No task starts your application or calls a model.
  """
  @impl true
  def run(args), do: ElixirAgentKit.CLI.run(:check, args)
end
