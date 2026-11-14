"""Check that each observable read contract accepts only its intended implementation."""
import os
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parent
for contract, opposite in [("target", "inverse"), ("inverse", "target")]:
    for source, expected in [(contract, 0), (opposite, 2)]:
        result = subprocess.run(
            ["elixir", "-r", "support.ex", "-r", source + ".ex", "holdout.exs"],
            cwd=root, env={**os.environ, "SCENARIO": contract},
            capture_output=True, text=True, timeout=30,
        )
        print(f"{contract} contract, {source} source: exit {result.returncode} (expected {expected})")
        if result.returncode != expected:
            raise SystemExit(result.stdout + result.stderr)
