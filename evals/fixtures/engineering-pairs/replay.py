"""Offline replay of the synthetic Elixir outputs, independent of any model."""
import json
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent


def exercise(code, assertions):
    with tempfile.TemporaryDirectory() as directory:
        script = Path(directory) / "check.exs"
        script.write_text(code + "\n" + assertions)
        run = subprocess.run(
            ["elixir", str(script)], cwd=directory, capture_output=True,
            text=True, timeout=20, check=False,
        )
        if run.returncode not in (0, 2):
            raise RuntimeError(run.stdout + run.stderr)
        return run.returncode == 0


def wrap(assertions):
    return (
        'ExUnit.start()\ndefmodule Holdout do\nuse ExUnit.Case\n'
        'test "contract" do\n' + assertions + '\nend\nend\n'
    )


def main():
    failures = []
    for case, specimen in json.loads((HERE / "cases.json").read_text()).items():
        for arm, code in specimen["returned_modules"].items():
            passed = exercise(code, wrap(specimen["checks"]))
            print(f"{case} {arm}: {'pass' if passed else 'fail'}")
            if not passed:
                failures.append((case, arm))
            if case == "data-contracts":
                if code.count("def max, do: 4") != 1:
                    raise ValueError("Expected a single literal owner in the recorded code")
                amended = code.replace("def max, do: 4", "def max, do: 2")
                if not exercise(amended, wrap(
                    'assert Batch.submit([1,2]) == :accepted\n'
                    'assert Batch.submit([1,2,3]) == {:error,:too_many}\n'
                    'assert View.hint() == "Up to 2 entries"'
                )):
                    failures.append((case, arm + " limit change"))
    for key, result in json.loads((HERE / "discoveries.json").read_text()).items():
        passed = exercise(result["code"], (HERE / "holdout.exs").read_text())
        print(f"{key}: {'pass' if passed else 'fail'} (expected {result['expected']})")
        if passed != (result["expected"] == "pass"):
            failures.append(key)
    if failures:
        raise SystemExit(f"Unexpected contract results: {failures}")


if __name__ == "__main__":
    main()
