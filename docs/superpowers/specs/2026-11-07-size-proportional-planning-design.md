---
status: approved
date: 2026-11-07
tags: [contract, planning, installer, evals]
---

# Size-proportional planning

## Problem

The kit has no planning rule that scales with the task. `START.md` asks for four
steps (risk, workflow, read, state the choice) and each workflow's first step
produces an artifact that acts as a small plan. Only `delivery-coordination`
carries a real plan template, and only when it is the selected workflow. Nothing
asks for a written plan before a large task, nothing survives context compaction,
and the 2026-11-06 live evaluation already shows runs ending at the turn cap
(E32-r1).

This is the first of three fronts. The others, out of scope here, are refactoring
workflows (functional thinking, readable code) and an evaluation matrix by
workflow and task size.

## Decisions

1. The rule lives in the shared contract and the `START.md` body, so all 34
   workflows inherit it. No workflow text changes. A separate `planning` workflow
   was rejected because `START.md` selects exactly one workflow and it would
   displace the domain workflow; a planning section in every `SKILL.md` was
   rejected as 34 copies that drift.
2. A large task stops for approval only when its plan widens the requested scope,
   changes persisted data or a public contract, or contains an irreversible step.
   Otherwise the agent proceeds, preserving finished deliveries.
3. Plans live in a kit-managed, git-ignored folder, `.elixir-agent-kit/plans/`.

## Size classification

`START.md` step 1, shared with the generated pointer skills, becomes:

> 1. Name the task's primary risk and its size (small, medium, large) in one line,
>    from the request alone. Revise the size after the first inspection when the
>    code shows otherwise.

Steps 2–4 are unchanged. A new step:

> 5. For a large task, write the plan in `.elixir-agent-kit/plans/` from the
>    task-plan template before the first edit, follow the contract's planning
>    rules and reread the plan after any compaction.

`CONTRACT.md` gains a section, "Plan in proportion to size", with this table:

| Size | Signals (any one raises the level) | Action |
|---|---|---|
| Small | A bounded, fully specified edit: one function or one file | No plan; usually workflow NONE |
| Medium | One flow or module, one workflow, one delivery | The workflow's first-step artifact is the plan, stated in the reply; no file |
| Large | Crosses more than one context or boundary; touches persisted data and code together; needs more than one delivery; an open request ("refactor module X"); or unlikely to fit one session without compaction | Plan file before the first edit |

Rules in the same section:

- Between two sizes, choose the larger.
- The plan does not replace the workflow: its first slice is the selected
  workflow's first-step artifact.
- Stop and ask only for the triggers in decision 2.
- The final report states the size next to the workflow ID.
- No numeric thresholds such as a file count: classification happens before the
  code is read, and a number becomes a target.

## Plan file

The installer writes `.elixir-agent-kit/plans/.gitignore`:

```
*
!.gitignore
```

It is an owned file recorded in `state.tsv` with its SHA-256. The consumer's own
`.gitignore` is never touched. `check` fails when it is missing or edited;
`uninstall` removes it and keeps any plan files, so a non-empty folder is not
pruned. The folder is not versioned: it supports resuming after compaction and in
another session of the same checkout, not in another worktree. Documentation
states that limit.

Plan files are named `.elixir-agent-kit/plans/YYYY-MM-DD-<slug>.md`, and the agent
names the path in its first message.

The template is `priv/library/templates/task-plan.md`, read from the dependency
like the other templates and never copied:

```markdown
# Task plan: <one line>

- Request, authorized scope and exclusions:
- Size and why; workflow ID and version:
- Baseline: branch, revision, pre-existing failures:
- Stop-and-ask triggers hit (scope, persisted data, public contract, irreversible): none | which

| # | Slice | Files/contracts | Check that proves it | Status |
|---|---|---|---|---|
| 1 | <first-step artifact of the workflow> | | | todo |

- Order and safe intermediate states:
- Stop conditions:
- Notes after compaction (what changed, what's next):
```

Usage rules in `CONTRACT.md`:

- Update the Status column as each slice closes; the plan is the task's state.
- After compaction or when resuming, reread the plan before any other action.
- Record a change of direction under Notes instead of deleting history; a change
  that hits a stop-and-ask trigger stops for the user.
- The final report, following `HANDOFF.md`, cites the plan path.

`delivery-coordination` keeps `delivery-plan.md` for multi-delivery work with
owners; `task-plan.md` covers one large task. A project with its own plan location
may say so in its instructions, and project rules keep precedence.

## Verification

Structural, run by `mix check` and CI:

- `test/installer_test.exs`: install creates and records
  `.elixir-agent-kit/plans/.gitignore`; check fails when it is missing or edited;
  sync from a 0.6.0 state adds it without touching other content; uninstall
  removes it, keeps a plan file and does not delete the non-empty folder.
- `scripts/check_library.py` requires the planning section and size table in
  `CONTRACT.md`, `templates/task-plan.md` with its required fields, and step 5 in
  the shared `START.md` body.
- `scripts/smoke_install.py` asserts the new file in a Git-sourced install.

Evaluation, a preview of the third front:

- Every case in `evals/routing.json` gains `expected_size`.
- Two new large cases, E51 and E52, with the success signal "plan file written
  before the first edit" and the failure signal "edited before planning".
- No model runs automatically. A live evaluation is manual, paid and reported
  separately from structural tests.

Documentation: `README.md` and its mirror `docs/README.pt-BR.md` (the `plans/`
row in "What lands in your project", step 5 in "What an agent does with it"),
`docs/architecture.md`, `docs/compatibility.md` (how a fresh session shows a large
task produced its plan) and `CHANGELOG.md`.

## Delivery

One pull request in this repository, then release 0.7.0 (minor: the installer
owns a new file). Updating pokex and Colmex to 0.7.0 follows in separate pull
requests.

## Out of scope

Refactoring workflows, the full workflow-by-size evaluation matrix, and any change
to the text of the 34 workflows.
