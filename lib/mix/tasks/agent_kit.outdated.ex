defmodule Mix.Tasks.AgentKit.Outdated do
  use Mix.Task
  @shortdoc "Query public release tags without updating the project"
  @moduledoc """
  Query stable vX.Y.Z tags in the official Git repository. Requires Git and network
  access; no token is required. Reports the loaded package version, not snapshot
  integrity. Use `mix agent_kit.check` for local installation drift.

      mix agent_kit.outdated
      mix agent_kit.outdated --check

  `--check` exits nonzero when a newer stable tag exists. Network failures always
  fail, never report up-to-date. No files, dependencies or applications are changed.
  """
  @impl true
  def run(args) do
    {opts, rest, invalid} = OptionParser.parse(args, strict: [check: :boolean])
    if rest != [] or invalid != [], do: Mix.raise("Expected only --check")

    case ElixirAgentKit.Releases.latest() do
      {:ok, latest} ->
        current = ElixirAgentKit.version()
        Mix.shell().info("Elixir Agent Kit: loaded #{current}; latest stable tag #{latest}.")

        if Version.compare(latest, current) == :gt do
          Mix.shell().info(
            "Review the release, update the tag, fetch dependencies and run mix agent_kit.sync."
          )

          if opts[:check], do: Mix.raise("A newer Elixir Agent Kit release is available")
        end

      {:error, reason} ->
        Mix.raise("Cannot determine latest release (#{reason}); freshness is unknown.")
    end
  end
end
