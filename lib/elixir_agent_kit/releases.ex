defmodule ElixirAgentKit.Releases do
  @moduledoc false
  @repository "https://github.com/sallaumen/elixir-agent-kit.git"

  @timeout 20_000

  def latest(repository \\ @repository, timeout \\ @timeout) do
    task =
      Task.async(fn ->
        System.cmd("git", ["ls-remote", "--tags", "--refs", repository],
          stderr_to_stdout: true,
          env: [{"GIT_TERMINAL_PROMPT", "0"}]
        )
      end)

    # A stalled network must fail, never hang the task indefinitely.
    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, {output, 0}} -> latest_stable(output)
      {:ok, {_output, _status}} -> {:error, :unavailable}
      {:exit, _reason} -> {:error, :unavailable}
      nil -> {:error, :timeout}
    end
  end

  def latest_stable(output) do
    versions =
      for line <- String.split(output, "\n", trim: true),
          [_hash, "refs/tags/v" <> tag] <- [String.split(line, "\t")],
          {:ok, version} <- [Version.parse(tag)],
          version.pre == [],
          version.build == nil,
          do: version

    case versions do
      [] -> {:error, :no_stable_release}
      _ -> {:ok, Enum.max_by(versions, & &1, Version)}
    end
  end
end
