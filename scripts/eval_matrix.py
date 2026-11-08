#!/usr/bin/env python3
"""Coverage and outcome matrix of routing cases by workflow and task size.

Reads evals/routing.json, priv/library/catalog.tsv and evals/results/*.tsv.
Calls no model and needs no network or third-party package.

Usage:
  python3 scripts/eval_matrix.py                 # coverage matrix
  python3 scripts/eval_matrix.py RESULTS.tsv...  # outcome matrix
"""
import csv
import io
import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SIZES = ("small", "medium", "large")
COLUMNS = ["run", "case", "client", "model", "kit", "routed", "size_stated",
           "plan", "outcome", "turns", "tokens", "notes"]
SIZE_STATED = set(SIZES) | {"none"}
PLANS = {"before_edit", "after_edit", "none", "review"}
OUTCOMES = {"finished", "turn_cap", "error"}


def _catalog(root):
    return [line.split("\t") for line in (root / "priv/library/catalog.tsv").read_text().splitlines()]


def load_cases(root=ROOT):
    data = json.loads((root / "evals/routing.json").read_text())
    return {case["id"]: case for case in data["cases"]}


def known_routes(root=ROOT):
    return {row[0] for row in _catalog(root)} | {"NONE", "EVOLUTION"}


def matrix_workflows(root=ROOT):
    return [row[0] for row in _catalog(root) if row[3] in ("code", "backend")]


def validate(text, source, cases, routes):
    """Return the valid rows of one result file and a list of 'source:line: reason' errors."""
    lines = list(csv.reader(io.StringIO(text), delimiter="\t", quoting=csv.QUOTE_NONE))
    if not lines or lines[0] != COLUMNS:
        return [], [f"{source}:1: header must be: {' '.join(COLUMNS)}"]
    rows, errors = [], []
    for number, values in enumerate(lines[1:], start=2):
        if not any(value.strip() for value in values):
            continue
        if len(values) != len(COLUMNS):
            errors.append(f"{source}:{number}: expected {len(COLUMNS)} columns, found {len(values)}")
            continue
        row = dict(zip(COLUMNS, values))
        problems = []
        if not row["run"]:
            problems.append("run is empty")
        if row["case"] not in cases:
            problems.append(f"unknown case {row['case']}")
        if row["routed"] not in routes:
            problems.append(f"unknown route {row['routed']}")
        if row["size_stated"] not in SIZE_STATED:
            problems.append(f"size_stated must be one of {sorted(SIZE_STATED)}")
        if row["plan"] not in PLANS:
            problems.append(f"plan must be one of {sorted(PLANS)}")
        if row["outcome"] not in OUTCOMES:
            problems.append(f"outcome must be one of {sorted(OUTCOMES)}")
        for key in ("turns", "tokens"):
            if row[key] and not row[key].isdigit():
                problems.append(f"{key} must be an integer or empty")
        errors.extend(f"{source}:{number}: {problem}" for problem in problems)
        if not problems:
            rows.append(row)
    return rows, errors


def routed_ok(case, row):
    return row["routed"] in [case["expected_primary"]] + case["allowed_alternatives"]


def plan_ok(case, row):
    if case["expected_size"] == "large":
        return row["plan"] in ("before_edit", "review")
    return row["plan"] == "none"


def _table(workflows, cell):
    lines = ["| Workflow | small | medium | large |", "|---|---|---|---|"]
    for workflow in workflows:
        lines.append(f"| {workflow} | " + " | ".join(cell(workflow, size) for size in SIZES) + " |")
    return "\n".join(lines) + "\n"


def coverage_matrix(cases, workflows):
    ids = defaultdict(list)
    for case in cases.values():
        ids[(case["expected_primary"], case["expected_size"])].append(case["id"])
    return _table(list(workflows) + ["NONE"], lambda w, s: ", ".join(ids[(w, s)]) or "-")


def outcome_matrix(rows, cases, workflows):
    groups = defaultdict(list)
    for row in rows:
        case = cases[row["case"]]
        groups[(case["expected_primary"], case["expected_size"])].append((case, row))
    extra = sorted({primary for primary, _ in groups} - set(workflows) - {"NONE"})

    def cell(workflow, size):
        runs = groups[(workflow, size)]
        if not runs:
            return "not run"
        total = len(runs)
        routed = sum(routed_ok(case, row) for case, row in runs)
        sized = sum(row["size_stated"] == case["expected_size"] for case, row in runs)
        planned = sum(plan_ok(case, row) for case, row in runs)
        finished = sum(row["outcome"] == "finished" for _, row in runs)
        return f"runs {total}; routed {routed}/{total}; size {sized}/{total}; plan {planned}/{total}; finished {finished}/{total}"

    return _table(list(workflows) + ["NONE"] + extra, cell)


def self_check(root=ROOT):
    """Run the validation and matrices on inline samples; return failures."""
    cases = load_cases(root)
    routes = known_routes(root)
    header = "\t".join(COLUMNS)
    valid = header + "\nE18-r1\tE18\tclaude-code 2.1\tsample-model\t0.8.0\tNONE\tsmall\tnone\tfinished\t3\t1200\t\n"
    invalid = header + "\nE999-r1\tE999\tclient\tmodel\t0.8.0\tNONE\tsmall\tmaybe\tfinished\tthree\t\t\n"
    failures = []
    rows, errors = validate(valid, "sample-valid", cases, routes)
    if errors or len(rows) != 1:
        failures.append(f"eval_matrix self-check: valid sample rejected: {errors}")
    elif "routed 1/1; size 1/1; plan 1/1; finished 1/1" not in outcome_matrix(rows, cases, matrix_workflows(root)):
        failures.append("eval_matrix self-check: outcome matrix miscounts the valid sample")
    rows, errors = validate(invalid, "sample-invalid", cases, routes)
    if rows or len(errors) != 3:
        failures.append(f"eval_matrix self-check: invalid sample should give 3 errors, got {errors}")
    if "E18" not in coverage_matrix(cases, matrix_workflows(root)):
        failures.append("eval_matrix self-check: coverage matrix misses NONE cases")
    return failures


def main(argv):
    cases = load_cases()
    workflows = matrix_workflows()
    if not argv:
        sys.stdout.write(coverage_matrix(cases, workflows))
        return 0
    routes = known_routes()
    rows, errors = [], []
    for name in argv:
        file_rows, file_errors = validate(Path(name).read_text(), name, cases, routes)
        rows.extend(file_rows)
        errors.extend(file_errors)
    if errors:
        sys.stderr.write("\n".join(errors) + "\n")
        return 1
    sys.stdout.write(outcome_matrix(rows, cases, workflows))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
