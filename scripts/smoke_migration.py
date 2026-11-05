#!/usr/bin/env python3
"""Migrate a real published 0.1.1 install in a disposable consumer."""
import os
from pathlib import Path
import subprocess
import tempfile
import json

package = Path(__file__).resolve().parents[1]

def run(root, *args, expected=0):
    result = subprocess.run(args, cwd=root, env=dict(os.environ, MIX_ENV="dev"),
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode != expected:
        raise SystemExit(f"Failed {args}: {result.stdout}")
    return result.stdout

with tempfile.TemporaryDirectory(prefix="eak-migration-") as tmp:
    root = Path(tmp)
    old_source = 'git: "https://github.com/sallaumen/elixir-agent-kit.git", tag: "v0.1.1"'
    project = '''defmodule Migration.MixProject do
  use Mix.Project
  def project do
    [app: :migration_smoke, version: "0.0.0",
     elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all],
     deps: [{:elixir_agent_kit, SOURCE, only: [:dev, :test], runtime: false}]]
  end
end
'''
    (root / "mix.exs").write_text(project.replace("SOURCE", old_source))
    original = "# Local instructions\nPreserve this exactly.\n"
    (root / "AGENTS.md").write_text(original)
    run(root, "mix", "deps.get")
    run(root, "mix", "agent_kit.install")
    assert len(list((root / ".agents/skills").glob("eak-*/SKILL.md"))) == 33
    own = root / ".agents/skills/local/SKILL.md"
    own.parent.mkdir(); own.write_text("Local skill")
    edited = root / ".elixir-agent-kit/library/CONTRACT.md"
    recorded = edited.read_bytes(); edited.write_text("Intentional local edit")
    (root / "mix.exs").write_text(project.replace("SOURCE", f'path: {json.dumps(str(package))}'))
    run(root, "mix", "deps.get")
    output = run(root, "mix", "agent_kit.sync", expected=1)
    assert "locally modified managed content" in output
    assert len(list((root / ".agents/skills").glob("eak-*/SKILL.md"))) == 33
    edited.write_bytes(recorded)
    run(root, "mix", "agent_kit.sync", "--dry-run")
    assert edited.exists()
    run(root, "mix", "agent_kit.sync")
    run(root, "mix", "agent_kit.check")
    assert "no changes needed" in run(root, "mix", "agent_kit.sync")
    assert not list((root / ".elixir-agent-kit/library").rglob("*.*"))
    assert not list((root / ".agents/skills").glob("eak-*/SKILL.md"))
    assert not list((root / ".claude/skills").glob("eak-*/SKILL.md"))
    assert own.read_text() == "Local skill"
    run(root, "mix", "agent_kit.uninstall")
    assert (root / "AGENTS.md").read_text() == original
    assert own.read_text() == "Local skill"
    print("OK: published v0.1.1 -> reference-only migration, edited-file refusal, local preservation, repeat sync and uninstall.")
