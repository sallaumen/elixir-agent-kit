---
name: code-consolidation
description: "Use when unfinished features, abandoned paths or competing implementations make a codebase ambiguous."
---

# Code Consolidation

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when unfinished features, abandoned paths or competing implementations make a codebase ambiguous.

## Inputs to inspect

- Similar implementations, their callers, differing inputs, outputs, side effects and test coverage.
- The reason each implementation exists, including version, tenant, performance and user experience constraints.

## Workflow

1. Inventory candidate paths and collect evidence of runtime use, tests, entry points and product intent. Classify each as useful and incomplete, obsolete, duplicated or uncertain.

2. Choose a destination for each candidate: finish, merge into a canonical implementation, remove with evidence, or defer with a specific question. Age and apparent inactivity are not proof of abandonment.

3. Trace dynamic references, jobs and stored data before removal. Preserve useful behavior and historical records. Avoid unrelated formatting and broad rewrites.

4. Complete one bounded cleanup and validate the surviving path, including a relevant failure case. State which uncertainty remains instead of describing the whole codebase as clean.

## Decision points

- Consolidate only when semantics and change cadence align; shared syntax alone is weak evidence.
- Choose an explicit shared boundary or keep variants when unification would create flags and special cases.

## Quality criteria

- The resulting API names the common concept and leaves meaningful differences visible at call sites.
- Error behavior, authorization, ordering and telemetry remain correct for every former caller.
- Removing duplication also removes obsolete tests/docs while retaining independent behavioral coverage.
- The new dependency direction does not make a lower layer import a product-specific caller.

## Validation and evidence

- Compare a representative normal and failure case for each variant before and after consolidation.
- Inspect all call sites and report the removed duplication and any deliberate variants retained.

## Avoid

- Do not extract a generic helper because two functions share a few lines.
- Do not hide divergent business rules behind Boolean switches.

## Completion

A recorded disposition for the selected candidates and a verified canonical path. Test duplication is handled by test-consolidation.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
