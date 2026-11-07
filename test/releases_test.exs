defmodule ElixirAgentKit.ReleasesTest do
  # PATH is process-global, so the stubbed git must not run beside other tests.
  use ExUnit.Case, async: false
  alias ElixirAgentKit.Releases

  test "stable releases use semantic order and ignore malformed, prerelease and build tags" do
    tags = ~w(v0.2.0 v0.10.0 v1.0.0-rc.1 v9.0.0+local vbroken release-99)
    output = Enum.map_join(tags, "\n", &"abc\trefs/tags/#{&1}")
    assert {:ok, version} = Releases.latest_stable(output)
    assert to_string(version) == "0.10.0"
    assert {:error, :no_stable_release} = Releases.latest_stable("abc\trefs/tags/v1.0.0-rc.1\n")
  end

  test "git query works against an isolated repository and fails for an unavailable remote" do
    root = Path.join(System.tmp_dir!(), "eak-release-#{System.unique_integer([:positive])}")
    File.mkdir_p!(root)
    on_exit(fn -> File.rm_rf!(root) end)
    {_, 0} = System.cmd("git", ["init", "--quiet", root])

    {_, 0} =
      System.cmd(
        "git",
        [
          "-c",
          "user.name=Test",
          "-c",
          "user.email=test@example.invalid",
          "commit",
          "--allow-empty",
          "-qm",
          "fixture"
        ],
        cd: root
      )

    {_, 0} = System.cmd("git", ["tag", "v0.2.0"], cd: root)
    assert {:ok, version} = Releases.latest(root)
    assert to_string(version) == "0.2.0"
    assert {:error, :unavailable} = Releases.latest(Path.join(root, "missing"))
  end

  test "a stalled git query times out instead of hanging" do
    stub = Path.join(System.tmp_dir!(), "eak-stub-git-#{System.unique_integer([:positive])}")
    File.mkdir_p!(stub)
    File.write!(Path.join(stub, "git"), "#!/bin/sh\nsleep 5\n")
    File.chmod!(Path.join(stub, "git"), 0o755)
    path = System.get_env("PATH")

    on_exit(fn ->
      System.put_env("PATH", path)
      File.rm_rf!(stub)
    end)

    System.put_env("PATH", stub <> ":" <> path)
    assert {:error, :timeout} = Releases.latest("ignored", 300)
  end

  test "outdated fails when the repository is unreachable and refuses stray arguments" do
    assert_raise Mix.Error, ~r/^Expected only --check$/, fn ->
      Mix.Tasks.AgentKit.Outdated.run(["extra"])
    end

    # A git that fails at once stands in for an unreachable repository, so the
    # task is exercised without the network and without touching any real config.
    stub = Path.join(System.tmp_dir!(), "eak-stub-git-#{System.unique_integer([:positive])}")
    File.mkdir_p!(stub)
    File.write!(Path.join(stub, "git"), "#!/bin/sh\necho 'fatal: stub' >&2\nexit 128\n")
    File.chmod!(Path.join(stub, "git"), 0o755)
    path = System.get_env("PATH")

    on_exit(fn ->
      System.put_env("PATH", path)
      File.rm_rf!(stub)
    end)

    System.put_env("PATH", stub <> ":" <> path)

    for args <- [[], ["--check"]] do
      assert_raise Mix.Error, ~r/Cannot determine latest release \(unavailable\)/, fn ->
        Mix.Tasks.AgentKit.Outdated.run(args)
      end
    end
  end
end
