defmodule ElixirAgentKit do
  @moduledoc """
  Project-local coding-agent practices, installed without network or model calls.

  See the Mix tasks for the supported command-line interface. The installer
  accepts an explicit project root to support isolated worktrees and tests.
  """

  @version Mix.Project.config()[:version]
  def version, do: @version

  def library_path do
    Application.app_dir(:elixir_agent_kit, "priv/library")
  end

  def catalog do
    library_path()
    |> Path.join("catalog.tsv")
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [id, mode, description] = String.split(line, "\t", parts: 3)
      %{id: id, mode: mode, description: description}
    end)
  end
end
