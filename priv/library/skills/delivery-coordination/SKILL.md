---
name: delivery-coordination
description: "Use when consolidating a product or dividing an authorized change into reviewable deliveries."
---

# Delivery Coordination

Default mode: **coordinate**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when an authorized change spans a migration, a context, a LiveView and an Oban worker and must land as reviewable pieces; when two or more agents or people will work on the same application at once and need non-overlapping files; when a product consolidation must decide which flows to finish, keep or retire before any branch is cut; when pieces started in parallel now conflict on `mix.lock`, a migration or a shared context; or when the user asks for a delivery plan with owners and order.

This workflow divides and sequences; it does not validate the result or design the gate. Whether an integrated delivery meets its criteria is [delivery-validation](../delivery-validation/SKILL.md). Which commands gate a delivery and how they run locally and in CI is [pipeline-design](../pipeline-design/SKILL.md). How a change is shaped so that pieces have clean boundaries is [architecture-review](../architecture-review/SKILL.md). Which revision of an artifact is current across pieces is [revision-lineage](../revision-lineage/SKILL.md).

## Inputs to inspect

- Start at: the authorization (what was approved, by whom, and whether delegation and parallel work are included), then `git status` and `git branch -a` for the integration baseline and the work already in progress.
- The repository's collaboration rules: branch naming, PR policy, required checks, who merges, and whether a shared checkout or worktrees are in use.
- The change mapped to files and contracts: migrations, schemas, contexts, LiveViews, workers, configuration, and which of them more than one piece would touch.
- Active branches and open PRs that touch the same files, and the handoffs already written for them.
- Evidence for a consolidation: usage of each flow, its owner, and whether removing it breaks a persisted record or a queued job. See [Ecto and migrations](../../ELIXIR.md#ecto-and-migrations) and [Oban](../../ELIXIR.md#oban).

## Workflow

1. Write the delivery table: slice, files and contracts it owns, depends on (another slice or nothing), acceptance check (the test or observation that says the slice is done), owner. Shared files (`mix.lock`, the router, a shared context) appear in exactly one row. Done when every file the change touches is in one row and no two rows claim the same file.

2. Order the rows: migrations and schema changes first, then contexts, then interface and workers, then cleanup; a row depends only on rows above it. Done when the order has no backward dependency and each row can be reviewed on its own.

3. Confirm the authority for the plan: which rows the session may execute, whether delegation is permitted, and who merges. Do not start parallel work without that authority; without it, execute the rows sequentially in order. Done when each row's executor is named or the plan is handed back for approval.

4. For each executed or delegated row, give the bounded assignment: the row, its owned files, the acceptance check and the base it branches from. Obtain the latest upstream state before branching. Done when every assignment has the four elements and the worker or the session has acknowledged it.

5. Integrate one row at a time: run its acceptance check against the integrated base, resolve conflicts by reading both sides, and update the table with its state (integrated, blocked, deferred). A worker's report is input to the check, not a substitute for it. Done when the row's acceptance check passed on the integrated base.

6. Record what remains: blocked rows with their blocker, deferred rows with their owner, temporary compatibility paths with their removal condition. Done when the table has no row without a state.

## Decision points

- One owner per shared file or contract; a second writer on the same file is a sequencing error, not a merge problem.
- At most two execution fronts by default when delegation is authorized; a third needs demonstrated independence in the table.
- A migration slice lands before the code that needs it and stays compatible with the code that precedes it; see [migration-compatibility](../migration-compatibility/SKILL.md).
- Missing configuration is not a broken feature; label it in the table instead of adding a slice to "fix" it.
- Rolling back a slice does not undo its migration, its persisted rows or its external effects; the table says what a rollback leaves behind.
- Coordination never grants authority to merge, publish or deploy.

## Quality criteria

- Every slice has an owner, owned files, dependencies, an acceptance check and a state.
- No two concurrent slices write the same file; `mix.lock` and migrations have one owner.
- Each slice is reviewable alone: a reviewer can read it without the later slices.
- Integration happened against the current base and conflicts were read, not auto-resolved.
- The handoff lists the remaining dependencies and who holds each.

## Validation and evidence

- Minimum: the delivery table with a state per slice and the acceptance check that passed for each integrated slice on the integrated base.
- When turns allow: the project gate on the integrated branch after the last slice.
- When delegation was used: each worker's handoff, and the acceptance check the session ran itself on the worker's result.
- When a PR exists: its check state and merge state as reported by the hosting service, not as assumed.

## Avoid

- Do not start parallel work without explicit authority; sequence it instead.
- Do not stage broadly in a shared checkout; stage by name within the slice.
- Do not treat a worker's report or an open PR as an integrated result.
- Do not infer merge or deploy permission from a collaboration template.
- Do not let two slices own one file to save a round of sequencing.

## Completion

A delivery table with one owner per slice and per shared file, an order with no backward dependency, each integrated slice proven by its acceptance check on the integrated base, and the remaining blocked and deferred rows with their holders. For checking the whole integrated change against its criteria use [delivery-validation](../delivery-validation/SKILL.md); for the gate commands and their parity use [pipeline-design](../pipeline-design/SKILL.md); for artifact revisions across slices use [revision-lineage](../revision-lineage/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
