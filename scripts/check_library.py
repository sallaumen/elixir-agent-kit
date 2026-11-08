#!/usr/bin/env python3
"""Check workflow metadata, structure, routing coverage, provenance and local Markdown links."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIBRARY = ROOT / "priv/library"
HEADINGS = [
    "## When to use",
    "## Inputs to inspect",
    "## Workflow",
    "## Decision points",
    "## Quality criteria",
    "## Validation and evidence",
    "## Avoid",
    "## Completion",
]
errors = []
contract = (LIBRARY / "CONTRACT.md").read_text()
if "## Plan in proportion to size" not in contract:
    errors.append("CONTRACT.md lacks the 'Plan in proportion to size' section")
for size in ["| Small |", "| Medium |", "| Large |"]:
    if size not in contract:
        errors.append(f"CONTRACT.md size table lacks the row {size}")
task_plan = LIBRARY / "templates/task-plan.md"
if not task_plan.is_file():
    errors.append("templates/task-plan.md is missing")
else:
    plan_text = task_plan.read_text()
    for field in [
        "- Request, authorized scope and exclusions:",
        "- Size and why; workflow ID and version:",
        "- Baseline: branch, revision, pre-existing failures:",
        "- Stop-and-ask triggers hit",
        "| # | Slice | Files/contracts | Check that proves it | Status |",
        "- Order and safe intermediate states:",
        "- Stop conditions:",
        "- Notes after compaction",
    ]:
        if field not in plan_text:
            errors.append(f"templates/task-plan.md lacks: {field}")


def heading_anchor(line):
    """GitHub-style anchor for a Markdown heading line."""
    text = line.lstrip("#").strip().lower()
    text = re.sub(r"[^\w\- ]", "", text)
    return text.replace(" ", "-")


rows = [line.split("\t") for line in (LIBRARY / "catalog.tsv").read_text().splitlines()]
ids = [row[0] for row in rows]
if len(ids) != len(set(ids)):
    errors.append("Duplicate catalog IDs")
actual_ids = {p.parent.name for p in (LIBRARY / "skills").glob("*/SKILL.md")}
if set(ids) != actual_ids:
    errors.append("Catalog and workflow directories disagree")
catalog_md = (LIBRARY / "CATALOG.md").read_text()
readme = (ROOT / "README.md").read_text()
provenance = (ROOT / "docs/provenance.md").read_text()
for skill_id, mode, description, area in rows:
    text = (LIBRARY / "skills" / skill_id / "SKILL.md").read_text()
    if not text.startswith(f'---\nname: {skill_id}\ndescription: {json.dumps(description)}\n---\n'):
        errors.append(f"Frontmatter mismatch: {skill_id}")
    if f"Default mode: **{mode}**" not in text:
        errors.append(f"Mode mismatch: {skill_id}")
    if area not in {"frontend", "backend", "code", "domains", "delivery"}:
        errors.append(f"Invalid area: {skill_id}")
    if f"| [{skill_id}](skills/{skill_id}/SKILL.md) | {mode} | {description} |" not in catalog_md:
        errors.append(f"Human catalog row differs from catalog.tsv: {skill_id}")
    if f"[{skill_id}](priv/library/skills/{skill_id}/SKILL.md)" not in readme:
        errors.append(f"README catalog table missing: {skill_id}")
    if f"`{skill_id}`" not in provenance:
        errors.append(f"Provenance missing: {skill_id}")
    found = [line for line in text.splitlines() if line.startswith("## ")]
    # The eight template headings must appear once each, in order; a workflow may add its own between them.
    if [h for h in found if h in HEADINGS] != HEADINGS:
        errors.append(f"Headings differ from the workflow template: {skill_id}")
    when = text.split("## When to use", 1)[1].split("## ", 1)[0].strip() if "## When to use" in text else ""
    if when == description or len(when) < len(description) + 80:
        errors.append(f"When to use only repeats the catalog sentence: {skill_id}")
    if not re.search(r"^- Start at:", text, re.M):
        errors.append(f"Inputs to inspect lacks a Start at line: {skill_id}")
    if not re.search(r"^- Minimum:", text, re.M):
        errors.append(f"Validation and evidence lacks a Minimum line: {skill_id}")
    if "—" in text:
        errors.append(f"Em dash in workflow text: {skill_id}")
    if re.search(r"/Users/|playwright|\bmcp\b", text, re.I):
        errors.append(f"Operator environment named in workflow text: {skill_id}")

cases = json.loads((ROOT / "evals/routing.json").read_text())["cases"]
case_ids = [case["id"] for case in cases]
if len(case_ids) != len(set(case_ids)):
    errors.append("Duplicate evaluation IDs")
primaries = {case["expected_primary"] for case in cases}
for skill_id in ids:
    if skill_id not in primaries:
        errors.append(f"No routing case expects: {skill_id}")
for case in cases:
    targets = [case["expected_primary"]] + case["allowed_alternatives"]
    if not set(targets) <= set(ids) | {"NONE", "EVOLUTION"}:
        errors.append(f"Unknown evaluation route: {case['id']}")
    if not all(case[field] for field in ["request", "success_signals", "failure_signals"]):
        errors.append(f"Incomplete evaluation case: {case['id']}")
    if case.get("expected_size") not in {"small", "medium", "large"}:
        errors.append(f"Evaluation case lacks expected_size small, medium or large: {case['id']}")
areas = {row[0]: row[3] for row in rows}
for skill_id in ids:
    if areas[skill_id] not in {"code", "backend"}:
        continue
    sizes = {case.get("expected_size") for case in cases if case["expected_primary"] == skill_id}
    for size in ["medium", "large"]:
        if size not in sizes:
            errors.append(f"No {size} evaluation case expects: {skill_id}")
small_none = [
    case for case in cases
    if case.get("expected_size") == "small"
    and "NONE" in [case["expected_primary"]] + case["allowed_alternatives"]
]
if len(small_none) < 4:
    errors.append(f"Fewer than four small evaluation cases accept NONE: {len(small_none)}")
evals_readme = (ROOT / "evals/README.md").read_text()
if f"These {len(cases)} cases" not in evals_readme:
    errors.append(f"evals/README.md does not state the case count {len(cases)}")

version = re.search(r'version: "([^"]+)"', (ROOT / "mix.exs").read_text()).group(1)
for rel in ["README.md", "docs/README.pt-BR.md", "docs/INSTALL_WITH_AI.md", "scripts/smoke_install.py"]:
    for tag in re.findall(r"\bv(\d+\.\d+\.\d+)\b", (ROOT / rel).read_text()):
        if tag != version:
            errors.append(f"Tag v{tag} in {rel} differs from mix.exs version {version}")

links = 0
paths = (
    list(LIBRARY.rglob("*.md"))
    + list((ROOT / "docs").rglob("*.md"))
    + list(ROOT.glob("*.md"))
    + list((ROOT / "evals").rglob("*.md"))
)
anchors = {}
for path in paths:
    anchors[path.resolve()] = {heading_anchor(l) for l in path.read_text().splitlines() if l.startswith("#")}
for path in paths:
    text = path.read_text()
    for target in re.findall(r'\]\(([^)]+)\)', text):
        if target.startswith(("https://", "http://", "mailto:")):
            if "github.com" in target and "/tree/" in target or "/blob/" in target:
                if LIBRARY in path.parents and not re.search(r"/(tree|blob)/[0-9a-f]{40}/", target):
                    errors.append(f"External skill link not pinned to a commit: {path.relative_to(ROOT)} -> {target}")
            continue
        file_part, _, fragment = target.partition("#")
        resolved = (path.parent / file_part).resolve() if file_part else path.resolve()
        links += 1
        if not resolved.is_relative_to(ROOT) or not resolved.is_file():
            errors.append(f"Broken/escaping link: {path.relative_to(ROOT)} -> {target}")
        elif fragment and resolved in anchors and fragment not in anchors[resolved]:
            errors.append(f"Missing anchor: {path.relative_to(ROOT)} -> {target}")
    if re.search(r'/Users/|gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{24,}', text):
        errors.append(f"Possible private path or credential: {path.relative_to(ROOT)}")

sys.path.insert(0, str(ROOT / "scripts"))
import eval_matrix  # noqa: E402

eval_cases = eval_matrix.load_cases(ROOT)
eval_routes = eval_matrix.known_routes(ROOT)
for result in sorted((ROOT / "evals/results").glob("*.tsv")):
    _, problems = eval_matrix.validate(result.read_text(), str(result.relative_to(ROOT)), eval_cases, eval_routes)
    errors.extend(problems)
errors.extend(eval_matrix.self_check(ROOT))

if errors:
    raise SystemExit("\n".join(errors))
print(f"OK: {len(ids)} workflows; structure, routing coverage, provenance and version aligned; {links} local links and anchors checked.")
