"""Replay two file layouts from a local Jason v1.4.4 clone; never edit the input."""
import io
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile

REV = "926d2ac6cc0271b9a7079b2ec16ae0cf802f7963"


def move_table(root, same_file):
    path = root / "lib/codegen.ex"
    source = path.read_text()
    public = source[source.index("  def jump_table("):source.index("  defmacro bytecase(")]
    private = source[source.index("  defp resize("):source.index("  defp encode_pair(")]
    table = "defmodule Jason.JumpTable do\n" + public + private + "end\n"
    source = source.replace(public, "").replace(private, "").replace(
        "jump_table = jump_table(", "jump_table = Jason.JumpTable.jump_table(")
    if same_file:
        source = table + "\n" + source
    else:
        (root / "lib/jump_table.ex").write_text(table)
    path.write_text(source)
    path = root / "lib/encode.ex"
    path.write_text(path.read_text().replace("Codegen, EncodeError", "JumpTable, EncodeError")
                    .replace("Codegen.jump_table(", "JumpTable.jump_table("))


def mix(root, env, *args):
    return subprocess.check_output(["mix", *args], cwd=root,
                                   env=dict(os.environ, MIX_ENV=env), text=True)


def replay(clone):
    archive = subprocess.check_output(["git", "-C", clone, "archive", REV])
    for variant in ("baseline", "same-file", "separate-file"):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with tarfile.open(fileobj=io.BytesIO(archive)) as files:
                files.extractall(root, filter="data")
            if variant != "baseline":
                move_table(root, variant == "same-file")
            mix(root, "test", "deps.get")  # Fetch upstream's locked test dependencies.
            mix(root, "prod", "compile")
            print(variant, flush=True)
            for label in ([], ["--label", "compile-connected"]):
                report = mix(root, "prod", "xref", "graph", "--format", "cycles", *label)
                print(" ".join(label) or "all labels", report, sep=":\n")
                if label and variant == "separate-file":
                    if report.strip() != "No cycles found":
                        raise SystemExit(f"Compile-connected cycle remains: {report}")
                else:
                    expected = {f"lib/{name}.ex" for name in ("codegen", "encode", "encoder")}
                    files = {line.split()[0] for line in report.splitlines()
                             if line.strip().startswith("lib/")}
                    if files != expected or "Cycle of length 3" not in report:
                        raise SystemExit(f"Unexpected file group: {report}")
            print(mix(root, "test", "test", "test/encode_test.exs", "test/helpers_test.exs",
                      "test/decode_test.exs"))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: replay.py /path/to/local/jason-clone")
    replay(sys.argv[1])
