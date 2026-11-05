defmodule ElixirAgentKit.Releases do
  @moduledoc false
  @repository "https://github.com/sallaumen/elixir-agent-kit.git"

  def latest(repository \\ @repository) do
    case System.cmd("git", ["ls-remote", "--tags", "--refs", repository],
           stderr_to_stdout: true,
           env: [{"GIT_TERMINAL_PROMPT", "0"}]
         ) do
      {output, 0} -> latest_stable(output)
      {_output, _status} -> {:error, :unavailable}
    end
  rescue
    _error in ErlangError -> {:error, :unavailable}
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
