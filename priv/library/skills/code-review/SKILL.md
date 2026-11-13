---
name: code-review
description: "Use when reviewing a bounded diff or pull request for actionable defects and regressions."
---

# Code Review

Default mode: **review**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a pull request or branch diff is ready and someone asks whether it is safe to merge; when a diff touches a context module, an Ecto schema or migration, a LiveView event handler or an Oban worker and the author wants defects found before integration; when a reviewer suspects a changed function has callers the diff does not show; when a change claims a test but the test does not reach the risky path; or when the request is "review this" with a base and a head.

This workflow reads a bounded diff and reports findings; it does not edit, comment or approve. When the question is whether an integrated revision meets its acceptance criteria rather than whether a diff is correct, use [delivery-validation](../delivery-validation/SKILL.md). When the question is which tests the project should have rather than whether this diff is covered, use [test-strategy](../test-strategy/SKILL.md). When a finding needs a root cause the diff alone cannot show, hand it to [debugging](../debugging/SKILL.md) instead of investigating inside the review.

## Size

- **Small**: review one changed function's behavior with one failure scenario, read-only; skip the full hunk table for the rest of the diff.
- **Medium**: run the workflow as written for one diff: the behavior table, the ranked findings and the covering-test checks.
- **Large**: a large diff across contexts; slice the review per changed behavior or area, and hand a root cause the diff cannot show to debugging or a coverage gap to test-strategy.

## Inputs to inspect

- Start at: the mandate (base, head, and what the change claims to do), then `git diff <base>...<head> --stat` to bound the files before reading any of them.
- The diff itself, read in dependency order: schemas and migrations, then contexts, then controllers, LiveViews and workers, then tests.
- Callers of every changed public function, found by grep on the function name and on behaviour callbacks; a changed contract with an unchanged caller is a finding candidate.
- The tests in the diff and the existing tests for the changed modules: which changed behavior each one exercises, and whether the assertion would fail if the change were reverted.
- Repository review rules and any contract the diff touches: authorization checks, tenant scoping, migration compatibility, PubSub topics, job uniqueness. See [Ecto and migrations](../../elixir/ecto.md) and [ExUnit and diagnostics](../../elixir/exunit.md).

## Workflow

1. List the changed behaviors as a table: behavior, file:line where it changes, the test that covers it or "none". Done when every hunk in the diff maps to a row and the uncovered rows are marked.

   If several rows have plausible failure scenarios and it is unclear which to trace first, use one signal from the checkout to choose: a changed branch the tests never enter, a caller that still expects the old result, or a prior fix to the same behavior in Git history. If that signal is inconclusive, continue in diff order. Skip this prioritization for a small review or when the priority is already clear; no analyzer or score is required.

   In the chosen row, note the signal and whether the code path or focused test confirmed the concern, ruled it out or left it open. For example: “Retry now reaches the send branch; the existing test exercises only the first attempt.” Check the other rows as usual. File churn alone says nothing about a particular function, and an empty caller search cannot rule out a configured callback.

2. Follow each changed behavior through its callers and the boundary it crosses (database, socket, job queue, provider). Done when each row names the callers that depend on it and whether they were updated.

3. For each row, ask what input or ordering makes the new code wrong: a nil, a concurrent write, a retried job, a stale assign, a tenant the query does not filter, a migration run against live data. Write the failure scenario or "none found". Done when every row has a scenario or an explicit "none found".

4. Classify each scenario: demonstrated (shown by reading the code path or by a focused test), likely (a reachable path with no counter-evidence), or question (needs the author). Done when no finding is unclassified.

5. Check the covering tests for the rows with scenarios: run the focused test with `mix test path:line` when the environment allows, and read the assertion. A test that passes with and without the change covers nothing. Done when each covering test is confirmed or demoted to "none".

6. Rank findings by consequence (data loss, security, wrong result, broken contract, missing coverage, style) and write each with file:line, trigger, consequence and evidence class. Done when a reader can act on the first finding without reading the rest.

7. State what was examined and what was not. Do not edit application code, post comments, approve or merge; those need separate authority. Done when the report names its limits.

## Decision points

- A finding needs a reachable path and a material consequence; a style preference without consequence is a note, not a finding.
- Severity follows user or data impact, not the size of the hunk.
- A missing test is a finding only when the uncovered behavior has a failure scenario; otherwise it is a coverage note.
- When the diff changes a contract (function signature, event name, schema field, job args), trace any unchanged caller against the new contract. Report which call or behavior can break; an unchanged caller may still be compatible.
- Uncertainty is stated as such; a hypothesis is never reported as a defect.
- In Elixir, check the defect classes the compiler and Credo do not catch: a lenient match that hides an impossible shape, a `with` whose `else` cannot tell which step failed, a raise that reaches a LiveView or controller, a server-set field in a `cast/3` list, a new compile-time dependency (`mix xref graph --format cycles --label compile-connected`), a process message sent from outside its owning module, an effect inside a transaction. Cite the anti-pattern name from [Module and function shape](../../elixir/code-shape.md) when one applies.

## Quality criteria

- Each finding cites file:line, the condition that triggers it and the resulting wrong behavior.
- The behavior table covers every hunk; a reviewer can check it against the diff in minutes.
- The review considers authorization, tenant scoping, migration safety, concurrency and job retries where the diff touches them.
- A clean review states what was examined, which tests were run and which risks were not checked.
- No application code was edited and no comment was published by the review itself.

## Validation and evidence

- Minimum: the behavior table (behavior, file:line, covering test or "none") and the ranked findings with a failure scenario each.
- When turns allow: run the focused tests for the rows with scenarios with `mix test path:line` and record pass or fail.
- When the diff touches a migration or schema: a note on whether the migration is safe against live data and existing rows.
- When a finding is classified as demonstrated: the exact code path or the test output that demonstrates it.

## Avoid

- Do not invent a defect from a generic checklist; every finding needs a path through this diff.
- Do not bury a blocker among cosmetic notes; rank by consequence.
- Do not edit the implementation, publish comments, approve or merge; the mode is review.
- Do not treat a passing suite as proof the changed behavior is covered; read the assertion.
- Do not expand into a root-cause investigation the diff cannot support; hand it off.

## Completion

A read-only assessment: a behavior table that maps every hunk to a covering test or "none", findings ranked by consequence with file:line and a failure scenario each, and a statement of what was and was not examined. No findings is not proof the change is correct. For a root cause the diff cannot show use [debugging](../debugging/SKILL.md); for the project's regression coverage use [test-strategy](../test-strategy/SKILL.md); for checking the integrated revision against its acceptance criteria use [delivery-validation](../delivery-validation/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
