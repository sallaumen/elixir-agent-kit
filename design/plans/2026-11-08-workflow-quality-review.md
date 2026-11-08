# Workflow quality review: implementation plan

**Goal:** Apply the six-check yardstick to all 38 workflows, fix every finding,
and add the machine checks that can catch regression.

**Architecture:** No new modules. The review is a read-and-fix pass over
`priv/library/skills/*/SKILL.md` and `priv/library/elixir/*.md`, followed by
targeted additions to `scripts/check_library.py`.

Spec: [workflow quality review](../specs/2026-11-08-workflow-quality-review-design.md).

## Global constraints

- Run after front 1 (size guides) is merged, because both edit the `SKILL.md`
  bodies; rebase on `origin/main` first.
- No em dash in `priv/library/`; no external source text; provenance unchanged.
- One fix per workflow per step; stage files by name; squash on merge.

---

### Task 1: Baseline and yardstick tooling

Record the current-version facts the review judges against (Elixir 1.19 commands
already fixed in 0.7, Phoenix 1.8 LiveView test rules, `Repo.transact/2`, Oban
`perform_job/3`). Write the six checks into the PR body. Add a failing
`check_library.py` check that greps `priv/library/` for known obsolete commands
(`mix xref callers`, `Repo.transaction(` used for multi-write) and for `elixir/*.md`
references that `ELIXIR.md` does not index. Run it to list the violations.

### Task 2: Review by area (parallel)

Review the five areas in parallel (one reviewer per area, using the yardstick):
frontend (8), backend (5), code (13), domains (8), delivery (4). Each reviewer
returns a finding table: workflow, check number, file:line, problem, fix. No
edits in this task.

### Task 3: Apply fixes

Apply the fixes one workflow at a time, in the area order, with no unrelated
changes. Re-run `mix check` and `check_library.py` after each area.

### Task 4: Machine checks

Finalize the `check_library.py` additions from Task 1 so they pass, and drop any
check that produces a false positive. Re-run the full gate.

### Task 5: Independent final review, PR, release

Have a reviewer that did not write the fixes review the full diff against the
yardstick. Fix its findings, run the full gate, push, open the PR, and after
merge release 0.10.0.
