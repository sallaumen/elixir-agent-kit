#!/usr/bin/env python3
"""Check public workflow metadata, provenance coverage and local Markdown links."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIBRARY = ROOT / "priv/library"
errors = []
rows = [line.split("\t") for line in (LIBRARY / "catalog.tsv").read_text().splitlines()]
ids = [row[0] for row in rows]
if len(ids) != len(set(ids)):
    errors.append("Duplicate catalog IDs")
actual_ids = {p.parent.name for p in (LIBRARY / "skills").glob("*/SKILL.md")}
if set(ids) != actual_ids:
    errors.append("Catalog and workflow directories disagree")
for skill_id, mode, description, area in rows:
    text = (LIBRARY / "skills" / skill_id / "SKILL.md").read_text()
    if not text.startswith(f'---\nname: {skill_id}\ndescription: {json.dumps(description)}\n---\n'):
        errors.append(f"Frontmatter mismatch: {skill_id}")
    if f"Default mode: **{mode}**" not in text:
        errors.append(f"Mode mismatch: {skill_id}")
    if area not in {"frontend", "backend", "cross-cutting", "delivery"}:
        errors.append(f"Invalid area: {skill_id}")
    if f"[{skill_id}](skills/{skill_id}/SKILL.md)" not in (LIBRARY / "CATALOG.md").read_text():
        errors.append(f"Human catalog missing: {skill_id}")
    if f"`{skill_id}`" not in (ROOT / "docs/provenance.md").read_text():
        errors.append(f"Provenance missing: {skill_id}")

cases = json.loads((ROOT / "evals/routing.json").read_text())["cases"]
case_ids = [case["id"] for case in cases]
if len(case_ids) != len(set(case_ids)):
    errors.append("Duplicate evaluation IDs")
for case in cases:
    targets = [case["expected_primary"]] + case["allowed_alternatives"]
    if not set(targets) <= set(ids) | {"NONE", "EVOLUTION"}:
        errors.append(f"Unknown evaluation route: {case['id']}")
    if not all(case[field] for field in ["request", "success_signals", "failure_signals"]):
        errors.append(f"Incomplete evaluation case: {case['id']}")

links = 0
paths = list(LIBRARY.rglob("*.md")) + list((ROOT / "docs").rglob("*.md")) + list(ROOT.glob("*.md")) + list((ROOT / "evals").glob("*.md"))
for path in paths:
    text = path.read_text()
    for target in re.findall(r'\]\(([^)]+)\)', text):
        if target.startswith(("https://", "http://", "#", "mailto:")):
            continue
        target = target.split("#", 1)[0]
        resolved = (path.parent / target).resolve()
        links += 1
        if not resolved.is_relative_to(ROOT) or not resolved.is_file():
            errors.append(f"Broken/escaping link: {path.relative_to(ROOT)} -> {target}")
    if re.search(r'/Users/|gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{24,}', text):
        errors.append(f"Possible private path or credential: {path.relative_to(ROOT)}")

if errors:
    raise SystemExit("\n".join(errors))
print(f"OK: {len(ids)} workflows; metadata and provenance aligned; {links} local links checked.")
