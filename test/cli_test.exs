defmodule ElixirAgentKit.CLITest do
  use ExUnit.Case, async: true
  alias ElixirAgentKit.CLI

  test "check refuses --dry-run because it is already read-only" do
    assert_raise Mix.Error, ~r/already read-only/, fn ->
      CLI.options!(:check, ["--dry-run"], nil)
    end
  end

  test "uninstall refuses selection flags" do
    for args <- [["--agents", "claude"], ["--skills", "debugging"]] do
      assert_raise Mix.Error, ~r/no selection flags/, fn ->
        CLI.options!(:uninstall, args, nil)
      end
    end
  end

  test "a non-keyword configuration is refused" do
    assert_raise Mix.Error, ~r/must be a keyword list/, fn ->
      CLI.options!(:install, [], [:codex])
    end
  end

  test "an unknown configuration key is refused" do
    assert_raise Mix.Error, ~r/Unknown Elixir Agent Kit configuration keys: \[:agent\]/, fn ->
      CLI.options!(:install, [], agent: [:codex])
    end
  end

  test "without a mix.exs entry and flags the recorded state decides the selection" do
    opts = CLI.options!(:sync, [], nil)
    refute Keyword.has_key?(opts, :agents)
    refute Keyword.has_key?(opts, :skills)
    assert opts[:dry_run] == false
  end

  test "a mix.exs entry is the source of truth and fills the missing key with its default" do
    opts = CLI.options!(:sync, [], agents: [:codex])
    assert opts[:agents] == [:codex]
    assert opts[:skills] == :all
    assert CLI.options!(:sync, [], skills: ["debugging"])[:agents] == [:generic]
  end

  test "flags override the mix.exs entry and split on commas" do
    opts =
      CLI.options!(:install, ["--agents", "codex,claude", "--skills", "a,b", "--dry-run"],
        agents: [:generic],
        skills: :all
      )

    assert opts[:agents] == ["codex", "claude"]
    assert opts[:skills] == ["a", "b"]
    assert opts[:dry_run] == true
  end

  test "stray arguments and invalid flags are refused" do
    for args <- [["extra"], ["--unknown"], ["--agents"], ["--dry-run=maybe"]] do
      assert_raise Mix.Error, ~r/^Expected --agents codex,claude,generic/, fn ->
        CLI.options!(:install, args, nil)
      end
    end
  end
end
