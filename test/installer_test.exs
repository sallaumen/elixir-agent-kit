defmodule ElixirAgentKit.InstallerTest do
  use ExUnit.Case, async: true
  alias ElixirAgentKit.Installer

  setup do
    root =
      Path.join(
        System.tmp_dir!(),
        "elixir-agent-kit-test-#{System.unique_integer([:positive, :monotonic])}"
      )

    File.mkdir_p!(root)
    on_exit(fn -> File.rm_rf!(root) end)
    %{root: root}
  end

  defp put(root, path, text) do
    path = Path.join(root, path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, text)
  end

  defp get(root, path), do: File.read!(Path.join(root, path))

  defp snapshot(root) do
    Path.wildcard(Path.join(root, "**/*"), match_dot: true)
    |> Enum.filter(&File.regular?/1)
    |> Map.new(&{Path.relative_to(&1, root), File.read!(&1)})
  end

  defp legacy_install(root) do
    Installer.run(:install, root, agents: [:codex, :claude])

    paths = [
      ".agents/skills/eak-debugging/SKILL.md",
      ".claude/skills/eak-debugging/SKILL.md",
      ".elixir-agent-kit/library/CONTRACT.md"
    ]

    hash = :crypto.hash(:sha256, "old generated content") |> Base.encode16(case: :lower)

    records =
      Enum.map_join(paths, "", fn path ->
        put(root, path, "old generated content")
        "file\t#{path}\t#{hash}\tcreated\n"
      end)

    File.write!(Path.join(root, ".elixir-agent-kit/state.tsv"), records, [:append])
  end

  test "migration removes legacy payload and wrappers but preserves local files", %{root: root} do
    legacy_install(root)
    put(root, ".agents/skills/my-own/SKILL.md", "keep")
    put(root, ".elixir-agent-kit/library/local-notes.md", "keep")
    before = snapshot(root)
    assert {:ok, [_ | _]} = Installer.run(:sync, root, dry_run: true)
    assert snapshot(root) == before
    assert {:ok, _} = Installer.run(:sync, root)
    refute File.exists?(Path.join(root, ".elixir-agent-kit/library/CONTRACT.md"))
    assert Path.wildcard(Path.join(root, ".agents/skills/eak-*/SKILL.md")) == []
    assert Path.wildcard(Path.join(root, ".claude/skills/eak-*/SKILL.md")) == []
    assert get(root, ".agents/skills/my-own/SKILL.md") == "keep"
    assert get(root, ".elixir-agent-kit/library/local-notes.md") == "keep"
    assert {:ok, []} = Installer.run(:check, root)
  end

  test "external path dependencies and spaces are encoded in references", %{root: root} do
    Installer.run(:install, root, library_path: "/tmp/my library(1)/priv/library")

    assert get(root, ".elixir-agent-kit/START.md") =~
             "/tmp/my%20library%281%29/priv/library/CONTRACT.md"
  end

  test "installs only references and round trips", %{root: root} do
    original = "# Project\nKeep this exact text.\n"
    put(root, "AGENTS.md", original)
    opts = [agents: [:codex, :claude, :generic]]
    assert {:ok, paths} = Installer.run(:install, root, opts)
    assert "CLAUDE.md" in paths
    assert get(root, "AGENTS.md") =~ original

    assert Enum.sort(Map.keys(snapshot(root))) ==
             [
               ".elixir-agent-kit/START.md",
               ".elixir-agent-kit/state.tsv",
               "AGENTS.md",
               "CLAUDE.md"
             ]

    assert get(root, ".elixir-agent-kit/START.md") =~
             "../deps/elixir_agent_kit/priv/library/CONTRACT.md"

    assert {:ok, []} = Installer.run(:check, root)
    assert {:ok, []} = Installer.run(:install, root, opts)
    assert {:ok, _} = Installer.run(:uninstall, root)
    assert get(root, "AGENTS.md") == original
    refute File.exists?(Path.join(root, "CLAUDE.md"))
    assert snapshot(root) == %{"AGENTS.md" => original}
    assert {:ok, []} = Installer.run(:uninstall, root)
  end

  test "a Claude block imports the managed AGENTS.md instead of repeating the reference",
       %{root: root} do
    Installer.run(:install, root, agents: [:codex, :claude])
    assert get(root, "AGENTS.md") =~ "START.md"
    assert get(root, "CLAUDE.md") =~ "\n@AGENTS.md\n"
    refute get(root, "CLAUDE.md") =~ "START.md"
    assert {:ok, []} = Installer.run(:check, root)
    Installer.run(:uninstall, root)
    refute File.exists?(Path.join(root, "CLAUDE.md"))
  end

  test "a Claude-only install imports an unmanaged AGENTS.md and keeps the reference",
       %{root: root} do
    put(root, "AGENTS.md", "# Mine\n")
    Installer.run(:install, root, agents: [:claude])
    assert get(root, "AGENTS.md") == "# Mine\n"
    claude = get(root, "CLAUDE.md")
    assert claude =~ "\n@AGENTS.md\n"
    assert claude =~ "START.md"
    assert {:ok, []} = Installer.run(:check, root)
  end

  test "a Claude-only install without AGENTS.md keeps the plain reference and detects a later one",
       %{root: root} do
    Installer.run(:install, root, agents: [:claude])
    refute get(root, "CLAUDE.md") =~ "@AGENTS.md"
    put(root, "AGENTS.md", "# Added later\n")
    assert {:drift, ["CLAUDE.md", ".elixir-agent-kit/state.tsv"]} = Installer.run(:check, root)
    assert {:ok, ["CLAUDE.md", ".elixir-agent-kit/state.tsv"]} = Installer.run(:sync, root)
    assert get(root, "CLAUDE.md") =~ "\n@AGENTS.md\n"
    assert get(root, "AGENTS.md") == "# Added later\n"
  end

  test "pre-existing empty instructions survive uninstall", %{root: root} do
    put(root, "AGENTS.md", "")
    Installer.run(:install, root)
    Installer.run(:uninstall, root)
    assert get(root, "AGENTS.md") == ""
  end

  test "dry run and missing-install check never write", %{root: root} do
    assert {:drift, [_ | _]} = Installer.run(:check, root)
    assert {:ok, [_ | _]} = Installer.run(:install, root, dry_run: true)
    assert snapshot(root) == %{}
  end

  test "local managed edits block all writes, including uninstall", %{root: root} do
    Installer.run(:install, root)
    put(root, ".elixir-agent-kit/START.md", "local change")
    before = snapshot(root)

    for action <- [:sync, :uninstall] do
      assert_raise ArgumentError, ~r/locally modified/, fn -> Installer.run(action, root) end
      assert snapshot(root) == before
    end

    assert {:drift, paths} = Installer.run(:check, root)
    assert ".elixir-agent-kit/START.md" in paths
    assert snapshot(root) == before
  end

  test "unmanaged collision refuses the entire install", %{root: root} do
    put(root, ".elixir-agent-kit/START.md", "mine")
    before = snapshot(root)

    assert_raise ArgumentError, ~r/unmanaged/, fn ->
      Installer.run(:install, root, agents: [:codex])
    end

    assert snapshot(root) == before
  end

  test "text added before and after the managed block remains byte-identical", %{root: root} do
    put(root, "AGENTS.md", "before\n")
    Installer.run(:install, root)
    File.write!(Path.join(root, "AGENTS.md"), "\nafter\n", [:append])
    assert {:ok, []} = Installer.run(:check, root)
    assert {:ok, []} = Installer.run(:sync, root)
    Installer.run(:uninstall, root)
    assert get(root, "AGENTS.md") == "before\n\nafter\n"
  end

  test "managed block edits are preserved and reported", %{root: root} do
    Installer.run(:install, root)
    path = Path.join(root, "AGENTS.md")
    File.write!(path, String.replace(File.read!(path), "For development tasks", "LOCAL"))
    before = snapshot(root)
    assert_raise ArgumentError, ~r/locally modified/, fn -> Installer.run(:sync, root) end
    assert snapshot(root) == before
  end

  test "malformed or duplicated markers refuse mutation", %{root: root} do
    for contents <- [
          "<!-- elixir-agent-kit:start -->",
          "<!-- elixir-agent-kit:end -->",
          "\n\n<!-- elixir-agent-kit:start -->\n<!-- elixir-agent-kit:end -->\n<!-- elixir-agent-kit:end -->\n"
        ] do
      put(root, "AGENTS.md", contents)
      assert_raise ArgumentError, ~r/malformed/, fn -> Installer.run(:install, root) end
      assert get(root, "AGENTS.md") == contents
    end
  end

  test "changing selection removes only owned instructions", %{root: root} do
    Installer.run(:install, root, agents: [:codex, :claude])
    put(root, ".agents/skills/my-own/SKILL.md", "keep")
    assert {:ok, _} = Installer.run(:sync, root, agents: [:codex], skills: ["debugging"])
    assert Path.wildcard(Path.join(root, ".claude/skills/*/SKILL.md")) == []
    assert get(root, ".agents/skills/my-own/SKILL.md") == "keep"
    assert Path.wildcard(Path.join(root, ".agents/skills/eak-*/SKILL.md")) == []
    assert get(root, ".elixir-agent-kit/START.md") =~ "`debugging`"
    refute get(root, ".elixir-agent-kit/START.md") =~ "`code-review`"
    assert {:ok, []} = Installer.run(:check, root)
  end

  test "an edited stale wrapper blocks pruning", %{root: root} do
    legacy_install(root)
    put(root, ".agents/skills/eak-debugging/SKILL.md", "preserve")
    before = snapshot(root)

    assert_raise ArgumentError, ~r/locally modified/, fn ->
      Installer.run(:sync, root, agents: [:generic])
    end

    assert snapshot(root) == before
  end

  test "deleted managed files are restored on sync", %{root: root} do
    Installer.run(:install, root)
    File.rm!(Path.join(root, ".elixir-agent-kit/START.md"))
    assert {:drift, _} = Installer.run(:check, root)
    assert {:ok, _} = Installer.run(:sync, root)
    assert {:ok, []} = Installer.run(:check, root)
  end

  test "invalid selections never write", %{root: root} do
    for opts <- [
          [agents: []],
          [agents: [:unknown]],
          [skills: ["unknown"]],
          [agents: :codex],
          [skills: []]
        ] do
      assert_raise ArgumentError, fn -> Installer.run(:install, root, opts) end
      assert snapshot(root) == %{}
    end
  end

  test "symlinked output directory is refused", %{root: root} do
    outside = Path.join(root, "outside")
    File.mkdir_p!(outside)
    File.ln_s!(outside, Path.join(root, ".elixir-agent-kit"))
    assert_raise ArgumentError, ~r/symlink/, fn -> Installer.run(:install, root) end
    assert File.ls!(outside) == []
  end

  test "symlinked instructions and broken symlinks are refused", %{root: root} do
    File.ln_s!(Path.join(root, "missing"), Path.join(root, "AGENTS.md"))
    assert_raise ArgumentError, ~r/symlink/, fn -> Installer.run(:install, root) end
    refute File.exists?(Path.join(root, "missing"))
  end

  test "malicious state cannot delete outside owned paths", %{root: root} do
    Installer.run(:install, root)
    put(root, "valuable.txt", "keep")
    state = get(root, ".elixir-agent-kit/state.tsv")
    hash = :crypto.hash(:sha256, "keep") |> Base.encode16(case: :lower)

    for path <- ["valuable.txt", ".elixir-agent-kit/library/../../valuable.txt"] do
      put(root, ".elixir-agent-kit/state.tsv", state <> "file\t#{path}\t#{hash}\tcreated\n")
      assert_raise ArgumentError, fn -> Installer.run(:uninstall, root) end
      assert get(root, "valuable.txt") == "keep"
    end
  end

  test "malformed state fails closed", %{root: root} do
    put(root, ".elixir-agent-kit/state.tsv", "not a manifest")
    assert_raise ArgumentError, ~r/invalid managed state/, fn -> Installer.run(:sync, root) end
  end

  test "duplicate ownership records fail closed", %{root: root} do
    Installer.run(:install, root)
    state = get(root, ".elixir-agent-kit/state.tsv")
    row = state |> String.split("\n", trim: true) |> List.last()
    put(root, ".elixir-agent-kit/state.tsv", state <> row <> "\n")
    assert_raise ArgumentError, ~r/duplicate/, fn -> Installer.run(:sync, root) end
  end

  test "extra unowned files survive uninstall", %{root: root} do
    Installer.run(:install, root)
    put(root, ".elixir-agent-kit/notes.md", "mine")
    Installer.run(:uninstall, root)
    assert get(root, ".elixir-agent-kit/notes.md") == "mine"
  end

  test "all installed local Markdown references resolve", %{root: root} do
    File.mkdir_p!(Path.join(root, "deps/elixir_agent_kit/priv"))

    File.cp_r!(
      ElixirAgentKit.library_path(),
      Path.join(root, "deps/elixir_agent_kit/priv/library")
    )

    Installer.run(:install, root, agents: [:codex, :claude, :generic])

    for {path, contents} <- snapshot(root),
        String.ends_with?(path, ".md"),
        [_, target] <- Regex.scan(~r/\]\(([^)]+)\)/, contents),
        not String.starts_with?(target, ["https://", "http://", "#"]) do
      target = target |> String.split("#") |> hd()
      resolved = Path.expand(target, Path.dirname(Path.join(root, path)))
      assert String.starts_with?(resolved, root <> "/"), "escape: #{path} -> #{target}"
      assert File.regular?(resolved), "broken link: #{path} -> #{target}"
    end
  end
end
