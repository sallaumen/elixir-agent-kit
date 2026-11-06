---
name: code-review
description: "Use when reviewing a bounded diff or pull request for actionable defects and regressions."
---

# Code Review

Default mode: **review**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when reviewing a bounded diff or pull request for actionable defects and regressions.

## Inputs to inspect

- The bounded diff, requested change, affected contracts and repository review rules.
- Relevant callers, tests and context needed to verify a suspected defect.

## Workflow

1. Read the mandate, base/head and project contracts before examining the diff. Follow changed behavior through relevant callers and boundaries.

2. Prioritize correctness, security, data integrity, compatibility and missing regression coverage. Explain each finding with a concrete trigger, consequence and precise location.

3. Separate demonstrated defects from hypotheses and stylistic preferences. Check whether existing tests actually exercise the risky path.

4. Return actionable findings ordered by severity, or state that no actionable defect was found within the reviewed scope. Do not edit, post comments, approve, merge or run effectful operations unless separately authorized.

## Decision points

- Prioritize actionable defects with a reachable path and material consequence.
- Separate a required fix from a suggestion or question; give uncertainty explicitly when evidence is incomplete.

## Quality criteria

- Each finding cites a tight location, conditions to reproduce and the resulting wrong behavior.
- Severity follows user or system impact, not style preference.
- The review considers contract drift, authorization, data consistency, migration and concurrency where the diff touches them.
- A clean review states what was examined and its limits instead of implying that every risk was ruled out.

## Validation and evidence

- Inspect the relevant neighboring code or run a focused check before asserting a defect.
- For each finding, provide a reproducing scenario or a direct contract contradiction.

## Avoid

- Do not invent a bug from a generic checklist.
- Do not bury a blocker among cosmetic observations.

## Completion

An independent read-only assessment with evidence and coverage limits. No findings is not proof that all behavior is correct.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
