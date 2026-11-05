#!/usr/bin/env python3
"""Exercise the real Mix consumer interface; local by default, Git optional."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
import re
from urllib.parse import unquote

parser = argparse.ArgumentParser()
parser.add_argument("--git-url", help="Fetch a real published Git dependency instead of the local package")
parser.add_argument("--ref", default="v0.2.0")
args = parser.parse_args()
package = Path(__file__).resolve().parents[1]


def run(root, *command, env_name="dev", expected=0):
    env = dict(os.environ, MIX_ENV=env_name)
    result = subprocess.run(command, cwd=root, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode != expected:
        raise SystemExit(f"Failed: {' '.join(command)} (exit {result.returncode})\n{result.stdout}")
    return result.stdout


def snapshot(root):
    return {str(p.relative_to(root)): p.read_bytes() for p in root.rglob("*")
            if p.is_file() and not any(part in {"_build", "deps", ".git"} for part in p.relative_to(root).parts)}


with tempfile.TemporaryDirectory(prefix="elixir-agent-kit-consumer-") as tmp:
    root = Path(tmp)
    source = (f'git: {json.dumps(args.git_url)}, ref: {json.dumps(args.ref)}' if args.git_url
              else f'path: {json.dumps(str(package))}')
    (root / "mix.exs").write_text('''defmodule Smoke.MixProject do
  use Mix.Project
  def project do
    [app: :kit_consumer_smoke, version: "0.0.0", elixir: "~> 1.15",
     elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all],
     deps: [{:elixir_agent_kit, ''' + source + ''', only: [:dev, :test], runtime: false}]]
  end
  def application, do: []
end
''')
    original = "# Consumer instructions\nPreserve me exactly.\n"
    (root / "AGENTS.md").write_text(original)
    run(root, "mix", "deps.get")
    listing = run(root, "mix", "agent_kit.list")
    assert "architecture-review" in listing and "delivery-validation" in listing
    run(root, "mix", "agent_kit.check", expected=1)
    before = snapshot(root)
    run(root, "mix", "agent_kit.install", "--dry-run")
    assert snapshot(root) == before, "dry run wrote project files"
    run(root, "mix", "agent_kit.install")
    run(root, "mix", "agent_kit.check")
    installed = snapshot(root)
    managed = set(installed) - set(before)
    assert managed == {".elixir-agent-kit/START.md", ".elixir-agent-kit/state.tsv", "CLAUDE.md"}, managed
    index = root / ".elixir-agent-kit/START.md"
    for target in re.findall(r'\]\(([^)]+)\)', index.read_text()):
        assert (index.parent / unquote(target)).is_file(), target
    assert not (root / ".agents").exists()
    assert not (root / ".claude").exists()
    assert not (root / ".elixir-agent-kit/library").exists()
    output = run(root, "mix", "agent_kit.install")
    assert "no changes needed" in output
    assert snapshot(root) == installed
    run(root, "mix", "agent_kit.check", env_name="test")
    run(root, "mix", "compile", "--warnings-as-errors", env_name="prod")
    assert "elixir_agent_kit" not in run(root, "mix", "deps", env_name="prod")
    run(root, "mix", "agent_kit.check", "--unknown", expected=1)
    run(root, "mix", "agent_kit.uninstall")
    assert (root / "AGENTS.md").read_text() == original
    assert not (root / ".elixir-agent-kit/state.tsv").exists()
    assert snapshot(root) == before, "uninstall did not restore consumer files"
    print("OK: real Mix consumer fetch, all adapters, dry run, drift exit, repeated install, test/prod isolation and uninstall.")
