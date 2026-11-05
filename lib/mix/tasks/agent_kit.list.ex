defmodule Mix.Tasks.AgentKit.List do
  use Mix.Task
  @shortdoc "List workflow IDs, modes and selection triggers"
  @moduledoc "Lists the bundled workflows. This command does not modify the project."

  @impl true
  def run([]) do
    Enum.each(ElixirAgentKit.catalog(), fn skill ->
      Mix.shell().info("#{skill.id} [#{skill.mode}]\n  #{skill.description}")
    end)
  end

  def run(_), do: Mix.raise("Usage: mix agent_kit.list")
end
