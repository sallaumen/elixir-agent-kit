---
name: delivery-validation
description: "Use when checking whether an integrated change actually satisfies its acceptance criteria."
---

# Delivery Validation

Default mode: **analyze**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a feature branch is merged and someone asks whether the request was actually delivered; when a release is tagged and consumers need confirmation that the documented install path works; when a worker or agent reports "done" and the integrated revision has not been checked against the original acceptance criteria; when a change claims a user flow (sign-up, checkout, a LiveView form) works but no one has run it on the integrated build; or when the requested outcome includes documentation, generated indexes or version pins that the test suite does not cover.

This workflow checks and reports; it does not fix, merge, publish or deploy. A defect in the diff before integration is [code-review](../code-review/SKILL.md). A defect found here that needs a cause is handed to [debugging](../debugging/SKILL.md) with the failing criterion. Which commands run as the gate is [pipeline-design](../pipeline-design/SKILL.md). Dividing the follow-up work the validation exposes is [delivery-coordination](../delivery-coordination/SKILL.md). Whether the validated revision is the one the lineage says is current is [revision-lineage](../revision-lineage/SKILL.md).

## Inputs to inspect

- Start at: the original request and its acceptance criteria (the issue, the PR description, the handoff), then the exact integrated revision: `git log -1` on the merged branch or tag, and `git diff <base>...<revision> --stat`.
- The repository's required gates and their last run on that revision, with the real check state from the hosting service when one exists.
- The user-facing flows the change claims, and how to exercise each on the integrated build: a test, a request, a headless browser run, a job enqueued and observed.
- Artifacts beyond code: documentation, generated catalogs or indexes, migrations and their rollback, version pins in consumers, release packages.
- Downstream consumers and the reference they install from. See [ExUnit and diagnostics](../../elixir/exunit.md) and [Build, dependencies and releases](../../elixir/build-releases.md).

## Workflow

1. Write the criteria table: each acceptance criterion, the evidence that will satisfy it (a named test, a flow exercised on the integrated build, an artifact inspected, a consumer install), and its state (pending). Add the implicit criteria the request carries: migrations run, docs match, pins updated. Done when every stated and implicit criterion has a row with its evidence named.

2. Pin the revision: confirm the branch, tag or merge commit under validation and that the working tree matches it. Done when the revision is recorded in the table header.

3. Collect evidence per row, cheapest first: run the named tests with `mix test path:line`, then the gate, then exercise the flows on the running integrated build (a browser run or a request for a LiveView, `Oban.Testing` or a real enqueue for a job), then inspect artifacts and consumer pins. Classify each piece as inspected, executed, simulated or unverified. Done when every row has evidence or a reason it could not be collected.

4. Compare each row's evidence with the criterion, not with the worker's report. A passing suite satisfies only the rows whose evidence names a test in it. Done when every row is passed, failed, blocked or deferred.

5. For a failed row, record the reproduction (command, observed, expected) and stop; do not repair. For a blocked row, name the authority or resource needed. Done when each non-passed row has a reproduction or a blocker.

6. Report the table with the revision, the evidence class per row, and the external actions still required (a tag to push, a consumer to update, monitoring to watch). Do not switch to repair, merge, publish or deploy. Done when the report distinguishes merged, released, installed and observed in use.

## Decision points

- Evidence is proportional to the changed risk: a doc change is inspected, a flow change is executed, a migration is run against representative data.
- Executed on the integrated build counts; executed on a worker's branch before integration does not.
- A versioned package is installable from its documented reference before any consumer pin moves.
- When a failed row needs a cause, route to [debugging](../debugging/SKILL.md) with the reproduction; the validation stays read-only.
- Stop collecting when the remaining risk is stated and bounded; validation does not aim at certainty.

## Quality criteria

- Every criterion maps to one piece of evidence with its class (inspected, executed, simulated, unverified) or a stated limitation.
- Merged, released, installed and observed in use are reported as separate states.
- Documentation, examples and generated indexes match the shipped revision.
- No application code was changed by the validation; failed rows carry a reproduction.
- The handoff names each external action and who holds it.

## Validation and evidence

- Minimum: the criteria table for the pinned revision with evidence class and state per row, and the reproduction for each failed row.
- When turns allow: the project gate run on the integrated revision, with its output.
- When the change claims a user flow: the flow exercised on the running integrated build, with what was observed at each step.
- When distribution changed: the package installed from its documented reference into a consumer and the consumer's smoke path run.

## Avoid

- Do not switch from validation to repair, merge, publish or deploy; the mode is analyze and application code stays untouched.
- Do not accept a worker's report, a screenshot or a passing suite as proof of a criterion they do not name.
- Do not validate a different revision than the one integrated.
- Do not describe a release as complete while consumers point at the old version.
- Do not claim live behavior from repository structure alone.

## Completion

A criteria table for the pinned integrated revision with evidence class and state per row, reproductions for failed rows, blockers for blocked rows, and the external actions that remain with their holders; no code changed. For a failed criterion's cause use [debugging](../debugging/SKILL.md); for sequencing the follow-up work use [delivery-coordination](../delivery-coordination/SKILL.md); for the gate commands themselves use [pipeline-design](../pipeline-design/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
