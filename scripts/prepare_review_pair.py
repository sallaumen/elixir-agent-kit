"""Prepare one blind review checkout without running a client or exposing evaluator files."""
import argparse
import io
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ARMS = {"old": "7be0224", "pilot": "d9c9811"}


def git(root, *args):
    return subprocess.check_output(["git", "-C", root, *args])


def snapshot(root, revision, *paths):
    with tarfile.open(fileobj=io.BytesIO(git(ROOT, "archive", revision, *paths))) as archive:
        archive.extractall(root, filter="data")


def prepare(root, case, arm):
    root = root.resolve()
    if root.is_relative_to(ROOT.resolve()):
        raise ValueError("use a directory outside the kit so parent instructions do not leak")
    root.mkdir()  # Refuse to touch an existing directory.
    git(root, "init", "-q")
    fixture = (json.loads((ROOT / "evals/fixtures/stock-review/snapshots.json").read_text())
               if case == "stock" else None)
    for stage in ("base", "candidate"):
        if fixture is not None:
            files = fixture["base"] if stage == "base" else fixture["head_replacements"]
            for name, body in files.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(body)
        else:
            snapshot(root, "3ceefe8" if stage == "base" else "7125df3", "mix.exs")
        git(root, "add", ".")
        git(root, "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
            "-c", "commit.gpgsign=false", "commit", "-qm", "Snapshot")
        git(root, "tag", stage)

    # Supply only the assigned guide; no sibling skill versions, git remote or oracle.
    with tempfile.TemporaryDirectory() as tmp:
        snapshot(tmp, ARMS[arm], "priv/library")
        shutil.copytree(Path(tmp) / "priv/library", root / "guide")
    question = ("Review this diff for reachable defects." if case == "stock"
                else "Review only this hunk: does Mix now report version 1.0.0?")
    (root / "BRIEF").write_text(question + "\nScope: git diff base candidate\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", choices=["stock", "version"])
    parser.add_argument("arm", choices=ARMS)
    parser.add_argument("directory", type=Path, help="New directory with an existing parent")
    args = parser.parse_args()
    prepare(args.directory, args.case, args.arm)
