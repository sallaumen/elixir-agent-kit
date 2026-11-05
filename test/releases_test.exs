defmodule ElixirAgentKit.ReleasesTest do
  use ExUnit.Case, async: true
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
end
