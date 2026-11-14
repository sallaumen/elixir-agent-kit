#!/usr/bin/env python3
"""Exercise the real Mix consumer interface; local by default, Git optional."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
import re
import shutil
from urllib.parse import unquote

parser = argparse.ArgumentParser()
parser.add_argument("--git-url", help="Fetch a real published Git dependency instead of the local package")
parser.add_argument("--ref", default="v1.2.1")
parser.add_argument("--deps-path", default="deps", help="Consumer dependency directory, relative to its root")
args = parser.parse_args()
if Path(args.deps_path).is_absolute() or ".." in Path(args.deps_path).parts:
    parser.error("--deps-path must stay inside the disposable consumer")
package = Path(__file__).resolve().parents[1]


def run(root, *command, env_name="dev", expected=0):
    env = dict(os.environ, MIX_ENV=env_name)
    result = subprocess.run(command, cwd=root, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode != expected:
        raise SystemExit(f"Failed: {' '.join(command)} (exit {result.returncode})\n{result.stdout}")
    return result.stdout


def snapshot(root):
    return {str(p.relative_to(root)): p.read_bytes() for p in root.rglob("*")
            if p.is_file() and (root / args.deps_path) not in p.parents
            and not any(part in {"_build", ".git"} for part in p.relative_to(root).parts)}


with tempfile.TemporaryDirectory(prefix="elixir-agent-kit-consumer-") as tmp:
    root = Path(tmp) / "original consumer"
    root.mkdir()
    source = (f'git: {json.dumps(args.git_url)}, ref: {json.dumps(args.ref)}' if args.git_url
              else f'path: {json.dumps(str(package))}')
    (root / "mix.exs").write_text(('''defmodule Smoke.MixProject do
  use Mix.Project
  def project do
    [app: :kit_consumer_smoke, version: "0.0.0", elixir: "~> 1.15",
     deps_path: DEPS_PATH,
     elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all],
     deps: [{:elixir_agent_kit, ''' + source + ''', only: [:dev, :test], runtime: false}]]
  end
  def application, do: []
end
''').replace('DEPS_PATH', json.dumps(args.deps_path)))
    original = "# Consumer instructions\nPreserve me exactly.\n"
    (root / "AGENTS.md").write_text(original)
    run(root, "mix", "deps.get")
    listing = run(root, "mix", "agent_kit.list")
    assert "architecture-review" in listing and "delivery-validation" in listing
    for area in ["Frontend and user experience", "Backend and data", "Code structure and quality",
                 "Operational domains", "Delivery and build"]:
        assert area in listing, area
    run(root, "mix", "agent_kit.check", expected=1)
    before = snapshot(root)
    run(root, "mix", "agent_kit.install", "--dry-run")
    assert snapshot(root) == before, "dry run wrote project files"
    install_output = run(root, "mix", "agent_kit.install")
    assert "Next: run mix agent_kit.check" in install_output, install_output
    run(root, "mix", "agent_kit.check")
    installed = snapshot(root)
    managed = set(installed) - set(before)
    pointers = {".agents/skills/elixir-agent-kit/SKILL.md", ".claude/skills/elixir-agent-kit/SKILL.md"}
    owned = {".elixir-agent-kit/START.md", ".elixir-agent-kit/plans/.gitignore", ".elixir-agent-kit/state.tsv", "CLAUDE.md"}
    assert managed == owned | pointers, managed
    assert (root / ".elixir-agent-kit/plans/.gitignore").read_text() == "*\n!.gitignore\n"
    generated = [root / ".elixir-agent-kit/START.md"] + [root / p for p in sorted(pointers)]
    for index in generated:
        for target in re.findall(r'\]\(([^)]+)\)', index.read_text()):
            assert (index.parent / unquote(target.split('#', 1)[0])).is_file(), (index.name, target)
    assert "\n@AGENTS.md\n" in (root / "CLAUDE.md").read_text(), "Claude block must import the managed AGENTS.md"
    assert "START.md" in (root / "AGENTS.md").read_text() and original in (root / "AGENTS.md").read_text()
    for p in pointers:
        text = (root / p).read_text()
        assert text.startswith("---\nname: elixir-agent-kit\n") and "## Inputs to inspect" not in text, p
    assert len(list((root / ".agents/skills").iterdir())) == 1 and len(list((root / ".claude/skills").iterdir())) == 1
    assert not (root / ".elixir-agent-kit/library").exists()
    output = run(root, "mix", "agent_kit.install")
    assert "no changes needed" in output
    assert snapshot(root) == installed
    if not args.git_url:
        # Selection flags override the mix.exs entry; a dry run reports and writes nothing.
        output = run(root, "mix", "agent_kit.sync", "--skills", "debugging,code-review", "--dry-run")
        assert "Would change" in output and ".elixir-agent-kit/START.md" in output, output
        assert snapshot(root) == installed, "selection dry run wrote project files"
        output = run(root, "mix", "agent_kit.check", "--agents", "codex", expected=1)
        assert "Out of sync: CLAUDE.md" in output, output
        assert snapshot(root) == installed, "check with a selection flag wrote project files"
        output = run(root, "mix", "agent_kit.uninstall", "--dry-run")
        assert "Would change" in output and "CLAUDE.md" in output, output
        assert snapshot(root) == installed, "uninstall dry run wrote project files"
        run(root, "mix", "agent_kit.uninstall", "--agents", "codex", expected=1)
        assert snapshot(root) == installed
    if args.git_url:
        for index in generated:
            assert all(not Path(unquote(target)).is_absolute()
                       for target in re.findall(r'\]\(([^)]+)\)', index.read_text())), index.name
        root = root.rename(Path(tmp) / "relocated consumer")
        run(root, "mix", "agent_kit.check")
        assert snapshot(root) == installed, "relocation changed generated references"
        generated = [root / ".elixir-agent-kit/START.md"] + [root / p for p in sorted(pointers)]
        for index in generated:
            for target in re.findall(r'\]\(([^)]+)\)', index.read_text()):
                assert (index.parent / unquote(target.split('#', 1)[0])).is_file(), (index.name, target)
        # A fresh dependency download must restore access without regenerating guidance.
        shutil.rmtree(root / args.deps_path)
        run(root, "mix", "deps.get")
        run(root, "mix", "agent_kit.check")
        assert snapshot(root) == installed, "dependency refetch changed consumer files"
    run(root, "mix", "agent_kit.check", env_name="test")
    run(root, "mix", "compile", "--warnings-as-errors", env_name="prod")
    assert "elixir_agent_kit" not in run(root, "mix", "deps", env_name="prod")
    run(root, "mix", "agent_kit.check", "--unknown", expected=1)
    run(root, "mix", "agent_kit.uninstall")
    assert (root / "AGENTS.md").read_text() == original
    assert not (root / ".elixir-agent-kit/state.tsv").exists()
    assert not (root / ".agents").exists() and not (root / ".claude").exists(), "uninstall left empty skill directories"
    assert snapshot(root) == before, "uninstall did not restore consumer files"
    if args.git_url:
        print(f"OK: relative Git references survive relocation and dependency refetch ({args.deps_path}).")
    print("OK: real Mix consumer fetch, all adapters, dry run, drift exit, repeated install, selection flags, "
          "dry-run uninstall, test/prod isolation and uninstall.")
