"""Report manually adjudicated reviews side by side. No model calls or keyword grading."""
import argparse
import json
from pathlib import Path

TARGETS = {"stock": {"receipt_scope", "last_date"}, "version": set()}


def score(runs):
    pairs = {}
    seen = set()
    for run in runs:
        case, rep, arm = run["case"], run["repeat"], run["arm"]
        if case not in TARGETS or type(rep) is not int or rep < 1 or arm not in {"old", "pilot"}:
            raise ValueError("invalid case, repeat or arm")
        pair = pairs.setdefault((case, rep), {})
        if arm in pair or not run["id"] or run["id"] in seen:
            raise ValueError("duplicate run or arm")
        seen.add(run["id"])
        grade = run["grade"]
        hits = grade["targets"]
        if len(set(hits)) != len(hits) or not set(hits) <= TARGETS[case]:
            raise ValueError("invalid or repeated target")
        if not run["final"].strip() or not grade["reason"].strip():
            raise ValueError("missing final answer or adjudication")
        extra, false = grade["other_confirmed"], grade["unsupported"]
        if not all(isinstance(items, list) and all(isinstance(i, str) and i.strip() for i in items)
                   for items in (extra, false)):
            raise ValueError("additional and unsupported findings must be listed")
        tokens = run["usage"]["output_tokens"]
        if type(tokens) is not int or tokens < 0 or not isinstance(run["calls"], list):
            raise ValueError("missing observed usage")
        total = len(hits) + len(extra) + len(false)
        found = f"{len(hits)}/{len(TARGETS[case])}" if TARGETS[case] else "n/a"
        precision = f"{total - len(false)}/{total}" if total else "n/a"
        pair[arm] = f"{found} | {precision} | {len(run['calls'])} | {tokens}"
    if not pairs or any(set(p) != {"old", "pilot"} for p in pairs.values()):
        raise ValueError("at least one complete pair required; unmatched arm")
    for (case, rep), arms in sorted(pairs.items()):
        for arm in ("old", "pilot"):
            yield f"| {case} | {rep} | {arm} | {arms[arm]} |"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", type=Path)
    args = parser.parse_args()
    try:
        rows = list(score(json.loads(args.results.read_text())))
    except (KeyError, ValueError, TypeError) as exc:
        parser.error(str(exc))
    print("| Case | Repeat | Arm | Targets found | Confirmed / reported | Shell calls | Output tokens |")
    print("|---|---:|---|---:|---:|---:|---:|")
    print(*rows, sep="\n")
