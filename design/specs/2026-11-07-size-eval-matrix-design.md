---
status: approved
date: 2026-11-07
tags: [evals, planning, scripts]
---

# Evaluation matrix by workflow and task size

## Problem

The owner wants an organized way to know whether the workflows work for small and
large tasks, and whether large tasks get their planning round. Today:

- 66 routing cases carry `expected_size`, but no workflow has cases at all three
  sizes and only 11 have a large case.
- Live evaluations are prose reports (`evals/results/*.md`) with run tables that
  differ per client; nothing aggregates them by workflow and size.
- The kit must not call models (AGENTS.md), so runs stay manual.

This is the third front, after size-proportional planning (0.7.0) and the
refactoring workflows (0.8.0).

## Decisions

1. The matrix varies task size only (small, medium, large), not the model's
   context window.
2. Coverage targets the 18 workflows in the `code` and `backend` areas: each gets
   at least one medium and one large case; small cases form a shared negative set.
3. Approach: structured result files plus an offline matrix script. A script that
   drives clients automatically was rejected because the kit adds no model calls.

## Cases and coverage

`scripts/check_library.py` requires that each workflow whose `catalog.tsv` area is
`code` or `backend` is the `expected_primary` of at least one `medium` case and at
least one `large` case, and that at least four `small` cases accept `NONE` (as
`expected_primary` or in `allowed_alternatives`).

Missing today, filled by new cases E67 to E81:

| Missing | Workflows |
|---|---|
| Large (12) | `security-boundaries`, `provider-calls`, `data-pipelines`, `abstraction-layers`, `module-design`, `code-consolidation`, `house-patterns`, `readable-code`, `test-strategy`, `code-review`, `performance`, `process-lifecycle` |
| Medium (3) | `data-contracts`, `migration-compatibility`, `architecture-review` |

E82 adds one small negative case (adding a `@spec` to a public function whose
types are already defined; expected `NONE`), so the small code and backend set is
E48, E54, E66 and E82.

What each size measures:

- Small: `NONE`, and no plan file; selecting a workflow or planning counts as a
  failure.
- Medium: the right workflow, the size stated, and the workflow's first-step
  artifact as the plan in the reply, with no plan file.
- Large: the right workflow, the size stated, and a plan in
  `.elixir-agent-kit/plans/` before the first edit; approval only on a real
  stop-and-ask trigger.

Modes that do not edit: for a large `code-review` (review mode) the success signal
is the large size stated, a written review plan and no edit; editing is a failure.

Every new large case carries the two shared signals (plan before the first edit;
editing before planning is a failure) and one workflow-specific signal drawn from
that workflow's first step. Requests are in Portuguese, as in the existing cases.

## Result files

Each live round writes `evals/results/YYYY-MM-DD-<client>.tsv`, one row per run,
with a header row and these tab-separated columns:

| Column | Values |
|---|---|
| `run` | an identifier such as `E70-r2` |
| `case` | an existing case ID |
| `client` | client and version |
| `model` | model name |
| `kit` | kit version |
| `routed` | a workflow ID, `NONE` or `EVOLUTION` |
| `size_stated` | `small`, `medium`, `large` or `none` (not stated) |
| `plan` | `before_edit`, `after_edit`, `none`, or `review` (a plan written in a mode that does not edit) |
| `outcome` | `finished`, `turn_cap` or `error` |
| `turns` | integer or empty |
| `tokens` | integer or empty |
| `notes` | free text |

Expected workflow and size are not columns; they come from `evals/routing.json` by
case ID, so they cannot drift.

## The matrix script

`scripts/eval_matrix.py`, Python standard library only, reads files and calls no
model:

- With no arguments: the coverage matrix (workflows in rows, small/medium/large
  in columns, case IDs per cell) for the 18 workflows plus `NONE`.
- With `.tsv` paths: the outcome matrix in Markdown. Per cell: runs; routed
  correctly (the expected workflow or an allowed alternative); size stated
  correctly; plan rule met (large: `before_edit` or `review`; small and medium:
  `none`); finished. Cells without runs show "not run".
- An unknown case ID, a value outside the lists or a missing column exits non-zero
  with the file, line and reason.

`check_library.py` imports the script's validation and applies it to every
`evals/results/*.tsv`, and runs the script's self-check on a valid and an invalid
inline sample, so CI catches a malformed result or a broken script.

## Live round procedure

A new section in `evals/README.md`:

1. Install the kit at a fixed version in a disposable worktree of a real consumer.
2. One fresh session per run: the case request, one sentence of project context,
   and a closing request to list the files read and the workflow chosen.
3. Fill the row from the transcript, which is the evidence.
4. An independent evaluator judges the success and failure signals.
5. Generate the matrix and commit the `.tsv` with a short Markdown summary.

`docs/compatibility.md` points to that section. The two existing prose reports
stay as they are.

## Verification

- `python3 scripts/check_library.py` (coverage rule, result validation, script
  self-check), `python3 -m pyflakes scripts/` (already in CI), `mix check`.
- No live round is part of this work; the first one is manual and paid.

## Delivery

One pull request. No release: `evals/` and `scripts/` are not in the package, so
consumers do not change.

## Out of scope

Live runs, the model context-window axis, the frontend, domain and delivery areas,
and any change to workflow text or the installer.
